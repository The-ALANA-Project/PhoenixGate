import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:phonix_scanner/models/contract_model.dart';
import 'package:phonix_scanner/models/settings_model.dart';
import 'package:phonix_scanner/screens/opening_screen.dart';
import 'package:phonix_scanner/screens/configuration_screen.dart';
import 'package:phonix_scanner/screens/scanning_screen.dart';
import 'package:phonix_scanner/screens/settings_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContractModel()),
        ChangeNotifierProvider(create: (_) => SettingsModel()),
      ],
      child: const PhonixScanner(),
    ),
  );
}

class PhonixScanner extends StatelessWidget {
  const PhonixScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settings, child) {
        return MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => OpeningScreen(),
            '/configuration': (context) => ConfigurationScreen(),
            '/scanning': (context) => ScanningScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
          theme: ThemeData(
            scaffoldBackgroundColor: settings.backgroundColor,
            textTheme: GoogleFonts.robotoTextTheme().apply(
              bodyColor: settings.fontColor,
              displayColor: settings.fontColor,
            ),
            primaryTextTheme: GoogleFonts.robotoTextTheme().apply(
              bodyColor: settings.fontColor,
              displayColor: settings.fontColor,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: settings.fontColor,
              iconTheme: IconThemeData(color: settings.fontColor),
              titleTextStyle: GoogleFonts.roboto(
                color: settings.fontColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: settings.highlightColor,
              selectionColor: settings.highlightColor,
              selectionHandleColor: settings.highlightColor,
            ),
          ),
        );
      },
    );
  }
}
