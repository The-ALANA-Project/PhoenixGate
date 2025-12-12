import 'package:flutter/material.dart';
import 'package:phonix_scanner/app_status_box.dart';
import 'package:phonix_scanner/models/blockchain_networks.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:phonix_scanner/contract_data_box.dart';
import 'package:phonix_scanner/event_data_box.dart';
import 'package:phonix_scanner/logo.dart';
import 'package:phonix_scanner/nfc_scan_area.dart';
import 'package:phonix_scanner/primary_button.dart';
import 'package:phonix_scanner/scan_instructions.dart';
import 'package:phonix_scanner/hyperlink.dart';
import 'package:provider/provider.dart';
import 'package:phonix_scanner/models/contract_model.dart';
import 'package:phonix_scanner/services/nfc_service.dart';
import 'package:phonix_scanner/services/blockchain_service.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  bool isScanning = false;
  bool isNfcAvailable = false;
  String? walletAddress;
  String? nfcError;
  bool isCheckingOwnership = false;
  String? ownershipError;
  // null = unknown/not checked yet, true = owns nft, false = does not own
  bool? ownershipResult;

  @override
  void initState() {
    super.initState();
    _initializeNfc();
  }

  Future<void> _initializeNfc() async {
    try {
      final available = await NfcService.initialize();
      setState(() {
        isNfcAvailable = available;
      });
    } catch (e) {
      setState(() {
        nfcError = 'NFC initialization failed: $e';
      });
    }
  }

  Future<void> _startNfcScan() async {
    if (!isNfcAvailable) await _initializeNfc(); // Refresh NFC availability

    if (!isNfcAvailable) {
      setState(() {
        nfcError = 'NFC is not available on this device';
      });
      return;
    }

    setState(() {
      isScanning = true;
      nfcError = null;
      walletAddress = null;
    });

    try {
      final address = await NfcService.startNfcSession();
      setState(() {
        walletAddress = address;
        isScanning = false;
      });

      if (address != null) {
        await _checkNftOwnership(address);
      }
    } catch (e) {
      setState(() {
        nfcError = 'NFC scan failed: $e';
        isScanning = false;
      });
    }
  }

  Future<void> _cancelNfcScan() async {
    await NfcService.cancelScan();
    setState(() {
      isScanning = false;
      nfcError = 'Scan cancelled';
    });
  }

  Future<void> _checkNftOwnership(String addressToCheck) async {
    final contractModel = context.read<ContractModel>();
    
    if (!contractModel.isValid) {
      setState(() {
        ownershipError = 'Invalid contract configuration';
      });
      return;
    }

    setState(() {
      isCheckingOwnership = true;
      ownershipError = null;
      ownershipResult = null;
    });

    try {
      final owns = await BlockchainService.checkNftOwnership(
        contractModel.blockchain!,
        contractModel.contractAddress,
        addressToCheck,
      );

      setState(() {
        ownershipResult = owns.ownership;
        nfcError = owns.error;
        isCheckingOwnership = false;
      });
    } catch (e) {
      setState(() {
        ownershipError = 'Failed to check ownership: $e';
        isCheckingOwnership = false;
        ownershipResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),
                const Logo(size: 75, isAnimated: true),

                const SizedBox(height: 20),
                const Text(
                  'Event Access',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Verify NFT membership with NFC scan',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: EventDataBox(),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Consumer<ContractModel>(
                    builder: (context, model, child) {
                      return ContractDataBox(
                        contractName: model.name,
                        blockchain: model.blockchain ?? BlockchainNetworks.ethereumMainnet,
                        address: model.contractAddress
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: const AppStatusBox(),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: NfcScanArea(
                    scanning: isScanning,
                    ownershipResult: ownershipResult,
                  ),
                ),

                const SizedBox(height: 12.0),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: PrimaryButton(
                        isScanning ? "Scanning..." : "Start NFC Scan",
                        () {
                          if (isScanning) {
                            _cancelNfcScan();
                          } else {
                            _startNfcScan();
                          }
                        },
                        icon: isScanning ? null : Icons.arrow_forward,
                      ),
                ),

                const SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: const ScanningInstructions(),
                ),

                const SizedBox(height: 36.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Powered By ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                    ),
                    Hyperlink(
                      text: 'Unlock Protocol',
                      url: 'https://unlock-protocol.com/',
                      color: AppColors.black,
                    ),
                    const Text(
                      ' x ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                    ),
                    Hyperlink(
                      text: 'Burner.pro',
                      url: 'https://www.burner.pro/',
                      color: AppColors.black,
                    ),
                  ],
                ),
                Text(
                  walletAddress != null
                      ? 'Wallet Address: $walletAddress'
                      : nfcError != null
                          ? 'Error: $nfcError'
                          : '',
                ),

                Text(
                  ownershipError != null ? 'Error: $ownershipError' : '',
                  style: const TextStyle(color: Colors.red),
                ),
                Text(
                  nfcError != null ? 'Error: $nfcError' : '',
                  style: const TextStyle(color: Colors.red),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}