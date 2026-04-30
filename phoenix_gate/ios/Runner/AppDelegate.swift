import Flutter
import UIKit
import CoreNFC

private final class IosNdefReaderChannel: NSObject, NFCNDEFReaderSessionDelegate {
  private var session: NFCNDEFReaderSession?
  private var pendingResult: FlutterResult?
  private var isBusy: Bool = false

  func attach(to channel: FlutterMethodChannel) {
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "UNAVAILABLE", message: "NFC reader unavailable", details: nil))
        return
      }

      switch call.method {
      case "startNdefSession":
        self.startNdefSession(call: call, result: result)
      case "stopSession":
        self.stopSession(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func startNdefSession(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard NFCNDEFReaderSession.readingAvailable else {
      result(FlutterError(code: "NFC_UNAVAILABLE", message: "NFC scanning is not supported on this device", details: nil))
      return
    }

    if isBusy {
      result(FlutterError(code: "SESSION_ACTIVE", message: "An NFC session is already active", details: nil))
      return
    }

    isBusy = true
    pendingResult = result

    let args = call.arguments as? [String: Any]
    let alertMessage = (args?["alertMessage"] as? String) ?? "Hold your iPhone near the Burner card."
    let invalidateAfterFirstRead = (args?["invalidateAfterFirstRead"] as? Bool) ?? true

    let newSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: invalidateAfterFirstRead)
    newSession.alertMessage = alertMessage
    session = newSession
    newSession.begin()
  }

  private func stopSession(result: @escaping FlutterResult) {
    session?.invalidate()
    session = nil

    if let pendingResult {
      self.pendingResult = nil
      isBusy = false
      pendingResult(nil)
    }

    result(nil)
  }

  // MARK: - NFCNDEFReaderSessionDelegate

  func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    guard let firstMessage = messages.first else {
      completeSuccess(value: nil, session: session)
      return
    }

    let extracted = extractFirstString(from: firstMessage)
    completeSuccess(value: extracted, session: session)
  }

  func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
    if tags.count > 1 {
      let retryInterval = DispatchTimeInterval.milliseconds(500)
      session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
      DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval) {
        session.restartPolling()
      }
      return
    }

    guard let tag = tags.first else {
      completeSuccess(value: nil, session: session)
      return
    }

    session.connect(to: tag) { error in
      if error != nil {
        self.completeError(code: "CONNECT_FAILED", message: "Unable to connect to tag.", details: error?.localizedDescription, session: session)
        return
      }

      tag.queryNDEFStatus { status, _, statusError in
        if status == .notSupported {
          self.completeError(code: "NOT_NDEF", message: "Tag is not NDEF compliant", details: nil, session: session)
          return
        }
        if statusError != nil {
          self.completeError(code: "QUERY_FAILED", message: "Unable to query NDEF status of tag", details: statusError?.localizedDescription, session: session)
          return
        }

        tag.readNDEF { message, readError in
          if readError != nil || message == nil {
            self.completeError(code: "READ_FAILED", message: "Failed to read NDEF from tag", details: readError?.localizedDescription, session: session)
            return
          }

          let extracted = self.extractFirstString(from: message!)
          self.completeSuccess(value: extracted, session: session)
        }
      }
    }
  }

  func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    // If we already completed, ignore.
    guard pendingResult != nil else {
      self.session = nil
      isBusy = false
      return
    }

    // Treat user cancel as a non-error (null result) to match Dart behavior.
    if let readerError = error as? NFCReaderError,
       readerError.code == .readerSessionInvalidationErrorUserCanceled {
      completeSuccess(value: nil, session: session)
      return
    }

    completeError(code: "SESSION_INVALIDATED", message: error.localizedDescription, details: nil, session: session)
  }

  // MARK: - Helpers

  private func completeSuccess(value: String?, session: NFCNDEFReaderSession) {
    guard let pendingResult else {
      self.session = nil
      isBusy = false
      return
    }

    self.pendingResult = nil
    self.session = nil
    isBusy = false

    DispatchQueue.main.async {
      pendingResult(value)
    }

    session.invalidate()
  }

  private func completeError(code: String, message: String, details: Any?, session: NFCNDEFReaderSession) {
    guard let pendingResult else {
      self.session = nil
      isBusy = false
      return
    }

    self.pendingResult = nil
    self.session = nil
    isBusy = false

    DispatchQueue.main.async {
      pendingResult(FlutterError(code: code, message: message, details: details))
    }

    session.invalidate()
  }

  private func extractFirstString(from message: NFCNDEFMessage) -> String? {
    guard let record = message.records.first else { return nil }

    switch record.typeNameFormat {
    case .nfcWellKnown:
      // Well-known types: "U" (URI) and "T" (Text)
      if let type = String(data: record.type, encoding: .utf8) {
        if type == "U", let url = record.wellKnownTypeURIPayload() {
          return url.absoluteString
        }
        if type == "T" {
          let (text, _) = record.wellKnownTypeTextPayload()
          if let text {
            return text
          }
        }
      }
      // Fall back to UTF-8 decoding of payload.
      return String(data: record.payload, encoding: .utf8)
    case .absoluteURI:
      return String(data: record.payload, encoding: .utf8)
    case .media:
      return String(data: record.payload, encoding: .utf8)
    case .nfcExternal, .unknown, .unchanged, .empty:
      return String(data: record.payload, encoding: .utf8)
    @unknown default:
      return String(data: record.payload, encoding: .utf8)
    }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let ndefReaderChannel = IosNdefReaderChannel()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "phonix_scanner/nfc_ndef", binaryMessenger: controller.binaryMessenger)
      ndefReaderChannel.attach(to: channel)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
