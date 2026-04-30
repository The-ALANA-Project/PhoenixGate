import 'package:flutter/foundation.dart';
import 'package:phonix_scanner/models/blockchain_networks.dart';

class ContractModel extends ChangeNotifier {

  String _contractAddress = '';

  BlockchainNetworks? _blockchain;

  String get contractAddress => _contractAddress;

  BlockchainNetworks? get blockchain => _blockchain;

  bool get isValid {
    if (_blockchain == null) return false;
    if (_contractAddress.isEmpty) return false;
    return _checkAddressPattern(_contractAddress);
  }

  bool get isAddressValid {
    if (_contractAddress.isEmpty) return false;
    return _checkAddressPattern(_contractAddress);
  }

  static bool _checkAddressPattern(String address) {
    final pattern = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return pattern.hasMatch(address);
  }

  set contractAddress(String value) {
    if (value == _contractAddress) return;
    _contractAddress = value;
    notifyListeners();
  }

  set blockchain(BlockchainNetworks? value) {
    if (value == _blockchain) return;
    _blockchain = value;
    notifyListeners();
  }
}