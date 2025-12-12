import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phonix_scanner/models/contract_model.dart';
import 'package:phonix_scanner/screens/opening_screen.dart';
import 'package:phonix_scanner/screens/configuration_screen.dart';
import 'package:phonix_scanner/screens/scanning_screen.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ContractModel(),
      child: const PhonixScanner(),
    )
  );
}

class PhonixScanner extends StatelessWidget {
  const PhonixScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => OpeningScreen(),
        '/configuration': (context) => ConfigurationScreen(),
        '/scanning': (context) => ScanningScreen(),
      },
    );
  }
}
