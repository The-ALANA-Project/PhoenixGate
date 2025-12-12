import 'package:http/http.dart';
import 'package:phonix_scanner/models/blockchain_networks.dart';
import 'package:web3dart/web3dart.dart' as web3dart;
import 'package:web3dart/web3dart.dart';

class Wrapper {
  bool? ownership;
  String? error;
}

class BlockchainService {
  static const Map<BlockchainNetworks, String> _rpcEndpoints = {
    BlockchainNetworks.ethereumMainnet: 'https://eth.llamarpc.com',
    BlockchainNetworks.polygon: 'https://polygon-bor-rpc.publicnode.com',
    BlockchainNetworks.optimism: 'https://optimism-rpc.publicnode.com',
    BlockchainNetworks.arbitrumOne: 'https://arbitrum-one-rpc.publicnode.com',
    BlockchainNetworks.base: 'https://base.llamarpc.com',
    BlockchainNetworks.gnosisChain: 'https://gnosis-rpc.publicnode.com',
  };

  static Future<Wrapper> checkNftOwnership(
    BlockchainNetworks blockchain,
    String contractAddress,
    String walletAddress,
  ) async {
    try {
      final rpcUrl = _rpcEndpoints[blockchain];
      if (rpcUrl == null) throw Exception('Unsupported blockchain network');

      final client = web3dart.Web3Client(rpcUrl, Client());

      const abi = '''
      [
        {
          "constant": true,
          "inputs": [{"name": "owner", "type": "address"}],
          "name": "balanceOf",
          "outputs": [{"name": "", "type": "uint256"}],
          "type": "function"
        }
      ]
      ''';

      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'ERC721'),
        EthereumAddress.fromHex(contractAddress),
      );

      final balanceOfFunction = contract.function('balanceOf');

      final result = await client.call(
        contract: contract,
        function: balanceOfFunction,
        params: [EthereumAddress.fromHex(walletAddress.toLowerCase())],
      );

      final balance = result.first as BigInt;

      await client.dispose();

      return Wrapper()..ownership = (balance > BigInt.zero);
    } catch (e) {
      return Wrapper()..error = 'Error checking NFT ownership: $e';
    }
  }
}