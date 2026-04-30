import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';

class InputFieldTitle extends StatelessWidget {
  const InputFieldTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final fontColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.font;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: fontColor,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
