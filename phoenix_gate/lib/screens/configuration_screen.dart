import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:phonix_scanner/configuration_block.dart';
import 'package:phonix_scanner/logo.dart';
import 'package:phonix_scanner/primary_button.dart';
import 'package:phonix_scanner/textbox.dart';
import 'package:phonix_scanner/secondary_button.dart';
import 'package:phonix_scanner/models/contract_model.dart';
import 'package:phonix_scanner/screens/settings_screen.dart';
import 'package:phonix_scanner/footer.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});
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

  void _cleanFields(BuildContext context) {
    final contractModel = Provider.of<ContractModel>(context, listen: false);
    contractModel.contractAddress = '';
    contractModel.blockchain = null;
  }

  @override
  Widget build(BuildContext context) {
    final fontColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.font;
    
    final highlightColor = Theme.of(context).textSelectionTheme.cursorColor ?? AppColors.fontHighlight;

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
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),
                const Logo(size: 75, isAnimated: true),
                const SizedBox(height: 20),
                Text(
                  'Membership Input',
                  style: TextStyle(fontSize: 24, color: highlightColor),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Configure the NFT contract to verify',
                    style: TextStyle(fontSize: 16, color: fontColor),
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
                      Navigator.pushNamed(context, '/'),
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
      bottomNavigationBar: const Footer(),
    );
  }
}
