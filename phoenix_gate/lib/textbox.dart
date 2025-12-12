import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:phonix_scanner/secondary_box.dart';

class TextBox extends StatelessWidget {
  const TextBox(this.text, this.alignment, {super.key});

  final String text;
  final TextAlign alignment;

  @override
  Widget build(BuildContext context) {
    return SecondaryBox(
      child: Text(
        text,
        textAlign: alignment,
        style: const TextStyle(
          fontSize: 14.0,
          color: AppColors.black,
        ),
      ),
    );
  }
}