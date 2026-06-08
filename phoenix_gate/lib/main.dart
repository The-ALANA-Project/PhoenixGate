import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:phoenix_gate/models/contract_model.dart';
import 'package:phoenix_gate/models/settings_model.dart';
import 'package:phoenix_gate/screens/opening_screen.dart';
import 'package:phoenix_gate/screens/configuration_screen.dart';
import 'package:phoenix_gate/screens/scanning_screen.dart';
import 'package:phoenix_gate/screens/settings_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContractModel()),
        ChangeNotifierProvider(create: (_) => SettingsModel()),
      ],
      child: const PhoenixGate(),
    ),
  );
}

class PhoenixGate extends StatelessWidget {
  const PhoenixGate({super.key});

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
