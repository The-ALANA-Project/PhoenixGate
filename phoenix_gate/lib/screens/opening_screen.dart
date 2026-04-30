import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:phonix_scanner/footer.dart';
import 'package:phonix_scanner/logo.dart';
import 'package:phonix_scanner/hyperlink.dart';
import 'package:phonix_scanner/screens/settings_screen.dart';
import 'package:phonix_scanner/widgets/background_animation.dart';

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final fontColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.font;
    final highlightColor =
      Theme.of(context).textSelectionTheme.cursorColor ??
      AppColors.fontHighlight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettingsSheet(context),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BackgroundAnimation(
        baseColor: Theme.of(context).scaffoldBackgroundColor,
        glowColor: highlightColor,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Logo(
                  size: 120,
                  isAnimated: true,
                  action: () => Navigator.pushNamed(context, '/configuration'),
                ),
                const SizedBox(height: 20),
                Text(
                  'PHOENIX GATE',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: highlightColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Verify your Memberships',
                  style: TextStyle(fontSize: 16, color: fontColor),
                ),
                const SizedBox(height: 10),
                Text(
                  'Powered By',
                  style: TextStyle(fontSize: 12, color: fontColor),
                ),
                const SizedBox(height: 10),
                Hyperlink(
                  text: 'Unlock Protocol',
                  url: 'https://unlock-protocol.com/',
                  color: highlightColor,
                ),
                const SizedBox(height: 10),
                Hyperlink(
                  text: 'Burner.pro',
                  url: 'https://www.burner.pro/',
                  color: highlightColor,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
