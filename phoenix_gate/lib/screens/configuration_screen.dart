import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:phonix_scanner/configuration_block.dart';
import 'package:phonix_scanner/logo.dart';
import 'package:phonix_scanner/primary_button.dart';
import 'package:phonix_scanner/textbox.dart';
import 'package:phonix_scanner/secondary_button.dart';
import 'package:phonix_scanner/models/contract_model.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  void _cleanFields(BuildContext context) {
    final contractModel = Provider.of<ContractModel>(context, listen: false);
    contractModel.name = '';
    contractModel.contractAddress = '';
    contractModel.blockchain = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),
                const Logo(size: 75, isAnimated: true),
                const SizedBox(height: 20),
                const Text(
                  'Membership Scan',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Configure the NFT contract to verify',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: const ConfigurationBlock(),
                ),
                const SizedBox(height: 24.0),
                Consumer<ContractModel>(
                  builder: (context, contractModel, child) {
                    final disabled = !contractModel.isValid;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: PrimaryButton(
                        "Continue to Scanner",
                        () => Navigator.pushNamed(context, '/scanning'),
                        disabled: disabled,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SecondaryButton(
                    'Back',
                    action: () => {
                      _cleanFields(context),
                      Navigator.pushNamed(context, '/')
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: const TextBox(
                    'This app will only verify membership NFTs from the specified contract address. Make sure the contract is deployed on the selected blockchain.',
                    TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}