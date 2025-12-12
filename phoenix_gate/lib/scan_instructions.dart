import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:phonix_scanner/secondary_box.dart';

const bigCircleRadius = 10.0;
const smallCircleRadius = 6.0;

class ScanningInstructions extends StatelessWidget {
  const ScanningInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return const SecondaryBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.circle, color: AppColors.white, size: bigCircleRadius),
              SizedBox(width: 8.0),
              Text(
                'How to Scan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          // Instructions
          SizedBox(height: 12.0),
          _Instruction('Ensure NFC is enabled on your device'),
          SizedBox(height: 12.0),
          _Instruction('Hold the Burner.pro card within 2cm of your phone'),
          SizedBox(height: 12.0),
          _Instruction('Keep the card steady during verification'),
        ],
      ),
    );
  }
}

class _Instruction extends StatelessWidget {
  const _Instruction(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: (bigCircleRadius - smallCircleRadius) / 2),
        Icon(Icons.circle, color: AppColors.black, size: smallCircleRadius),
        SizedBox(width: 8.0),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }
}