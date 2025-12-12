import 'package:flutter/material.dart';
import 'package:phonix_scanner/models/blockchain_networks.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:phonix_scanner/secondary_box.dart';

class ContractDataBox extends StatelessWidget {
  const ContractDataBox({super.key, this.contractName = '', required this.blockchain, required this.address});

  final String contractName;
  final BlockchainNetworks blockchain;
  final String address;

  String _shortenAddress(String addr) {
    if (addr.length <= 10) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryBox(child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.circle, color: AppColors.contractIcon, size: 10),
                SizedBox(width: 8),
                Text(
                  "Contract Configured",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contractName,
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  _shortenAddress(address),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  blockchain.name,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/configuration');
          },
          child: const Icon(Icons.settings_outlined, size: 18),
        ),
      ],
    ));
  }
}