import 'package:flutter/material.dart';
import 'package:phoenix_gate/models/blockchain_networks.dart';
import 'package:phoenix_gate/colors.dart';
import 'package:phoenix_gate/contract_data_box.dart';
import 'package:phoenix_gate/logo.dart';
import 'package:phoenix_gate/nfc_scan_area.dart';
import 'package:phoenix_gate/primary_button.dart';
import 'package:phoenix_gate/scan_instructions.dart';
import 'package:phoenix_gate/hyperlink.dart';
import 'package:provider/provider.dart';
import 'package:phoenix_gate/models/contract_model.dart';
import 'package:phoenix_gate/screens/settings_screen.dart';
import 'package:phoenix_gate/services/nfc_service.dart';
import 'package:phoenix_gate/services/blockchain_service.dart';
import 'package:phoenix_gate/footer.dart';

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

  final List<String> _logs = [];

  Future<void> _openSettingsSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: screenHeight * 0.8,
        child: const SettingsScreen(isBottomSheet: true),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeNfc();
    _runOwnershipTest();
  }

  Future<void> _runOwnershipTest() async {
    const testWallet = '0xaBD303449eFCB3d266bC2a2e4448c89E4a652d99';
    const testContract = '0x399dd7186e6c696306909c9d08f5ae23b0e9c6f5';
    const testNetwork = BlockchainNetworks.base;

    setState(() {
      _logs.add('--- Running Static Ownership Test ---');
    });

    try {
      final result = await BlockchainService.checkNftOwnership(
        testNetwork,
        testContract,
        testWallet,
      );
      setState(() {
        _logs.add('Test Result: Ownership = ${result.ownership}');
        if (result.error != null) {
          _logs.add('Test Error: ${result.error}');
        }
        _logs.addAll(result.logs);
        _logs.add('--- Static Ownership Test Finished ---');
      });
    } catch (e) {
      setState(() {
        _logs.add('!!! Static Ownership Test Failed: $e !!!');
      });
    }
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
      _logs.clear();
      _logs.add('--- Checking NFT Ownership ---');
    });

    try {
      final owns = await BlockchainService.checkNftOwnership(
        contractModel.blockchain!,
        contractModel.contractAddress,
        addressToCheck,
      );

      setState(() {
        ownershipResult = owns.ownership;
        ownershipError = owns.error;
        isCheckingOwnership = false;
        _logs.addAll(owns.logs);
        _logs.add('--- Ownership Check Finished ---');
      });
    } catch (e) {
      setState(() {
        ownershipError = 'Failed to check ownership: $e';
        isCheckingOwnership = false;
        ownershipResult = null;
        _logs.add('!!! Ownership Check Failed: $e !!!');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color:
              Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.font,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettingsSheet(context),
          ),
        ],
      ),
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
                Text(
                  'Event Access',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).textSelectionTheme.cursorColor ??
                        AppColors.font,
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  'Verify NFT membership with NFC scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        Theme.of(context).textTheme.bodyMedium?.color ??
                        AppColors.font,
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Consumer<ContractModel>(
                    builder: (context, model, child) {
                      return ContractDataBox(
                        blockchain:
                            model.blockchain ??
                            BlockchainNetworks.ethereumMainnet,
                        address: model.contractAddress,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: NfcScanArea(
                    scanning: isScanning,
                    ownershipResult: ownershipResult,
                    onTap: () {
                      if (isScanning) {
                        _cancelNfcScan();
                      } else {
                        _startNfcScan();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: const ScanningInstructions(),
                ),

                //Text(
                //  walletAddress != null
                //      ? 'Wallet Address: $walletAddress'
                //      : nfcError != null
                //          ? 'Error: $nfcError'
                //          : '',
                //),
                if (walletAddress != null || nfcError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      walletAddress != null
                          ? 'Wallet Address: $walletAddress'
                          : nfcError != null
                          ? 'NFC Error: $nfcError'
                          : '',
                      style: TextStyle(
                        color: nfcError != null
                            ? Colors.red
                            : Theme.of(context).textTheme.bodyMedium?.color ??
                                  AppColors.black,
                      ),
                    ),
                  ),
                if (ownershipError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Ownership Error: $ownershipError',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                /*
                if (_logs.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(24.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Logs:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        ..._logs.map(
                          (log) => Text(
                            log,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                */
                //Text(
                //  ownershipError != null ? 'Error: $ownershipError' : '',
                //  style: const TextStyle(color: Colors.red),
                //),
                //Text(
                //  nfcError != null ? 'Error: $nfcError' : '',
                //  style: const TextStyle(color: Colors.red),
                //)
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
