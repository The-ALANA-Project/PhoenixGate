import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:phonix_scanner/secondary_box.dart';

const bigCircleRadius = 10.0;
const smallCircleRadius = 6.0;

class ScanningInstructions extends StatelessWidget {
  const ScanningInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    final fontColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.font;
    
    final highlightColor = Theme.of(context).textSelectionTheme.cursorColor ?? AppColors.fontHighlight;

    return SecondaryBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Text(
                'How to Scan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: highlightColor,
                ),
              ),
            ],
          ),

          // Instructions
          SizedBox(height: 12.0),
          const _Instruction('Ensure NFC is enabled on your device'),
          const SizedBox(height: 12.0),
          const _Instruction(
            'Hold the Burner.pro card within 2cm of your phone',
          ),
          const SizedBox(height: 12.0),
          const _Instruction('Keep the card steady during verification'),
        ],
      ),
    );
  }
}

class _Instruction extends StatelessWidget {
  const _Instruction(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final fontColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.font;

    return Row(
      children: [
        const SizedBox(width: (bigCircleRadius - smallCircleRadius) / 2),
        Icon(Icons.circle, color: fontColor, size: smallCircleRadius),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 14, color: fontColor)),
        ),
      ],
    );
  }
}
