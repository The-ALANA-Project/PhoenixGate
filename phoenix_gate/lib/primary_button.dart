import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.text, this.action, {super.key, this.disabled = false, this.icon = Icons.arrow_forward});

  final String text;
  final VoidCallback action;
  final bool disabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? null : () {
        action();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled ? AppColors.disabledPrimaryButton : AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      ),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 16),
        if (icon != null) Icon(icon),
      ],
      ),
    );
  }
}