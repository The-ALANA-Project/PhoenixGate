enum BlockchainNetworks {
  ethereumMainnet,
  polygon,
  optimism,
  arbitrumOne,
  base,
  gnosisChain,
}

extension BlockchainNetworksExtension on BlockchainNetworks {
  String get displayName {
    switch (this) {
      case BlockchainNetworks.ethereumMainnet:
        return 'Ethereum Mainnet';
      case BlockchainNetworks.polygon:
        return 'Polygon';
      case BlockchainNetworks.optimism:
        return 'Optimism';
      case BlockchainNetworks.arbitrumOne:
        return 'Arbitrum One';
      case BlockchainNetworks.base:
        return 'Base';
      case BlockchainNetworks.gnosisChain:
        return 'Gnosis Chain';
    }
  }
}

