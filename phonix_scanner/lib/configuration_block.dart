import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:phonix_scanner/input_field.dart';
import 'package:phonix_scanner/input_field_title.dart';
import 'package:phonix_scanner/drop_down.dart';
import 'package:phonix_scanner/models/blockchain_networks.dart';
import 'package:phonix_scanner/models/contract_model.dart';
import 'package:provider/provider.dart';

class ConfigurationBlock extends StatefulWidget {
  const ConfigurationBlock({super.key});

  @override
  State<ConfigurationBlock> createState() => _ConfigurationBlockState();
}

class _ConfigurationBlockState extends State<ConfigurationBlock> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();

    final model = Provider.of<ContractModel>(context, listen: false);
    _nameController.text = model.name;
    _addressController.text = model.contractAddress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contractModel = Provider.of<ContractModel>(context);

    final addressNonEmpty = contractModel.contractAddress.isNotEmpty;
    final addressValid = contractModel.isAddressValid;
    final addressInvalid = addressNonEmpty && !addressValid;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.white30,
          width: 1.0,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputFieldTitle('Contract Name (Optional)'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: InputField(
                suggestion: 'e.g., VIP Membership Pass',
                controller: _nameController,
                onChanged: (value) {
                  contractModel.name = value;
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputFieldTitle('Blockchain Network'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: CustomDropDown(
                items: [
                  BlockchainNetworks.ethereumMainnet,
                  BlockchainNetworks.polygon,
                  BlockchainNetworks.optimism,
                  BlockchainNetworks.arbitrumOne,
                  BlockchainNetworks.base,
                  BlockchainNetworks.gnosisChain,
                ],
                selectedValue: contractModel.blockchain,
                onChanged: (value) {
                  contractModel.blockchain = value;
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputFieldTitle('Smart Contract Address'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: InputField(
                suggestion: '0x...',
                controller: _addressController,
                onChanged: (value) {
                  contractModel.contractAddress = value;
                },
                // if invalid, show it
                suffix: addressInvalid
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
                errorText: addressInvalid ? 'Invalid contract address' : null,
              ),
            ),
          ]
        ),
      ),
    );
  }
}