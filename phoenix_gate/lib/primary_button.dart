import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:provider/provider.dart';
import 'package:phonix_scanner/models/settings_model.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.text,
    this.action, {
    super.key,
    this.disabled = false,
    this.icon = Icons.arrow_forward,
  });

  final String text;
  final VoidCallback action;
  final bool disabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    final fontColor = settings.fontColor;
    final buttonColor = settings.buttonColor;

    final ButtonStyle style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return buttonColor.withAlpha(127);
        }
        return buttonColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return fontColor.withAlpha(50);
        }
        return fontColor;
      }),
      side: WidgetStateProperty.resolveWith<BorderSide?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: AppColors.white30);
        }
        return BorderSide(color: AppColors.white30);
      }),
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      ),
    );

    return ElevatedButton(
      onPressed: disabled
          ? null
          : () {
              action();
            },
      style: style,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 16),
          if (icon != null) Icon(icon),
        ],
      ),
    );
  }
}
