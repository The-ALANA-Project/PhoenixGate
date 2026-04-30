import 'package:http/http.dart';
import 'package:phonix_scanner/models/blockchain_networks.dart';
import 'package:web3dart/web3dart.dart' as web3dart;
import 'package:web3dart/web3dart.dart';

class Wrapper {
  bool? ownership;
  String? error;
  List<String> logs = [];
}

class BlockchainService {
  static const Map<BlockchainNetworks, String> _rpcEndpoints = {
    BlockchainNetworks.ethereumMainnet: 'https://eth.llamarpc.com',
    BlockchainNetworks.polygon: 'https://polygon-bor-rpc.publicnode.com',
    BlockchainNetworks.optimism: 'https://optimism-rpc.publicnode.com',
    BlockchainNetworks.arbitrumOne: 'https://arbitrum-one-rpc.publicnode.com',
    BlockchainNetworks.base: 'https://base-rpc.publicnode.com',
    BlockchainNetworks.gnosisChain: 'https://gnosis-rpc.publicnode.com',
  };

  static Future<Wrapper> checkNftOwnership(
    BlockchainNetworks blockchain,
    String contractAddress,
    String walletAddress,
  ) async {
    web3dart.Web3Client? client;

    final wrapper = Wrapper();
    wrapper.logs.add('Starting ownership check...');
    wrapper.logs.add('Blockchain: $blockchain');
    wrapper.logs.add('Contract Address: $contractAddress');
    wrapper.logs.add('Wallet Address: $walletAddress');

    try {
      final rpcUrl = _rpcEndpoints[blockchain];
      if (rpcUrl == null) throw Exception('Unsupported blockchain network');

      wrapper.logs.add('Using RPC URL: $rpcUrl');

      client = web3dart.Web3Client(rpcUrl, Client());

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

      wrapper.logs.add('Contract deployed.');

      final balanceOfFunction = contract.function('balanceOf');

      wrapper.logs.add('Got balanceOf function.');

      final params = [EthereumAddress.fromHex(walletAddress.toLowerCase())];
      wrapper.logs.add('Calling contract with params: $params');


      final result = await client.call(
        contract: contract,
        function: balanceOfFunction,
        params: params,
      );

      wrapper.logs.add('Contract call result: $result');

      if (result.isEmpty || result.first is! BigInt) {
        wrapper.ownership = false;
        wrapper.logs.add('Result is empty or not a BigInt. Ownership set to false.');
        return wrapper;
      }

      final balance = result.first as BigInt;
      wrapper.logs.add('Balance is: $balance');
      wrapper.ownership = (balance > BigInt.zero);
      wrapper.logs.add('Ownership determined: ${wrapper.ownership}');
      return wrapper;
    } on RangeError catch (e, s) {
      // Most commonly happens when the call returns empty/invalid data
      // (wrong contract, wrong chain, or non-ERC721 ABI) and web3dart can't decode.
      // Treat as "no ownership" for UX.
      wrapper.ownership = false;
      wrapper.logs.add('RangeError caught: $e. Ownership set to false.');
      wrapper.logs.add('Stacktrace: $s');
      return wrapper;
    } on FormatException catch (e, s) {
      wrapper.ownership = false;
      wrapper.logs.add('FormatException caught: $e. Ownership set to false.');
      wrapper.logs.add('Stacktrace: $s');
      return wrapper;
    } on ArgumentError catch (e, s) {
      wrapper.ownership = false;
      wrapper.logs.add('ArgumentError caught: $e. Ownership set to false.');
      wrapper.logs.add('Stacktrace: $s');
      return wrapper;
    } catch (e, s) {
      wrapper.error = 'Error checking NFT ownership: $e';
      wrapper.logs.add('Generic error: $e');
      wrapper.logs.add('Stacktrace: $s');
      return wrapper;

    } finally {
      if (client != null) {
        await client.dispose();
        wrapper.logs.add('Client disposed.');
      }
    }
  }
}