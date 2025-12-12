import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/digests/keccak.dart';

class NfcService {
  static bool _isAvailable = false;
  static bool get isAvailable => _isAvailable;

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
          NfcPollingOption.iso18092,
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

                RegExp regex = RegExp(r'pkN=([a-fA-F0-9]+)&attN');
                var match = regex.firstMatch(url);

                if (match == null) {
                  throw ArgumentError('No valid pkN=...&attN substring found');
                }

                String extracted = match.group(1)!;

                // Step 2: Remove the first 6 characters (4 char prefix added by the card and the 04 byte)
                if (extracted.length <= 6) {
                  throw ArgumentError('The extracted string is too short');
                }
                String modified = extracted.substring(6);

                List<int> bytes = hex.decode(modified);

                final keccak = KeccakDigest(256);
                final hash = keccak.process(Uint8List.fromList(bytes));

                final last20 = hex.encode(hash.sublist(hash.length - 20));
                return '0x$last20';
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
}