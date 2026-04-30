import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/digests/keccak.dart';

class NfcService {
  static bool _isAvailable = false;
  static bool get isAvailable => _isAvailable;

  static const MethodChannel _iosNdefChannel = MethodChannel('phonix_scanner/nfc_ndef');

  static bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static Future<bool> initialize() async {
    try {
      _isAvailable = await NfcManager.instance.isAvailable();
      return _isAvailable;
    } catch (e) {
      _isAvailable = false;
      return false;
    }
  }

  static Future<String?> startNfcSession() async {
    if (!_isAvailable) {
      throw Exception('NFC is not available on this device');
    }

    if (_isIOS) {
      final String? extracted = await _iosNdefChannel.invokeMethod<String>(
        'startNdefSession',
        {
          'alertMessage': 'Hold your iPhone near the Burner card.',
          'invalidateAfterFirstRead': true,
        },
      );
      if (extracted == null || extracted.isEmpty) {
        return null;
      }
      return _walletAddressFromExtractedString(extracted);
    }

    String? result;
    bool sessionCompleted = false;

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            result = await _readWalletAddress(tag);
            sessionCompleted = true;
            await NfcManager.instance.stopSession();
          } catch (e) {
            sessionCompleted = true;
            await NfcManager.instance.stopSession();
            rethrow;
          }
        },
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          //NfcPollingOption.iso18092,
          ...NfcPollingOption.values,
        },
      );

      // Wait for either tag detection or timeout
      const timeoutDuration = Duration(seconds: 30);
      final startTime = DateTime.now();
      
      while (!sessionCompleted && 
             DateTime.now().difference(startTime) < timeoutDuration) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (!sessionCompleted) {
        await NfcManager.instance.stopSession();
        throw Exception('NFC scan timeout - no tag detected within 30 seconds');
      }

    } catch (e) {
      if (!sessionCompleted) {
        await NfcManager.instance.stopSession();
      }
      rethrow;
    }

    return result;
  }

  static Future<void> stopSession() async {
    try {
      if (_isIOS) {
        await _iosNdefChannel.invokeMethod<void>('stopSession');
        return;
      }
      await NfcManager.instance.stopSession();
    } catch (e) {
      // Todo: handle error if needed
    }
  }

  static Future<void> cancelScan() async {
    await stopSession();
  }

  static Future<String?> _readWalletAddress(NfcTag tag) async {
    
    try {
      final Ndef? ndef = Ndef.from(tag);
      if (ndef != null) {
        
        try {
          final ndefMessage = await ndef.read();
          if (ndefMessage != null && ndefMessage.records.isNotEmpty) {
            if (ndefMessage.records.isNotEmpty) {
              if (ndefMessage.records.first.payload.isNotEmpty) {
                Uint8List payloadBytes = ndefMessage.records.first.payload;
                String url = String.fromCharCodes(payloadBytes);

                return _walletAddressFromExtractedString(url);
              } else {
                throw ArgumentError('NDEF record payload is empty');
              }
            }
          } else {
            //Todo: ('NDEF tag is empty');
          }
        } catch (e) {
          //Todo: ('Error reading NDEF: $e');
        }
      } else {
        //Todo: ('No NDEF support detected');
      }

    } catch (e) {
      //Todo: ('Technology detection error: $e');
    }
    
    return null;
  }

  static String? _walletAddressFromExtractedString(String extractedString) {
    try {
      final regex = RegExp(r'pkN=([a-fA-F0-9]+)&attN');
      final match = regex.firstMatch(extractedString);

      if (match == null) {
        return null;
      }

      final extracted = match.group(1);
      if (extracted == null || extracted.length <= 6) {
        return null;
      }

      // Remove the first 6 characters (4 char prefix added by the card and the 04 byte)
      final modified = extracted.substring(6);
      final bytes = hex.decode(modified);

      final keccak = KeccakDigest(256);
      final hash = keccak.process(Uint8List.fromList(bytes));
      final last20 = hex.encode(hash.sublist(hash.length - 20));
      return '0x$last20';
    } catch (_) {
      return null;
    }
  }
}