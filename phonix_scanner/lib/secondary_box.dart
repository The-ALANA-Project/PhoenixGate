import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';

class SecondaryBox extends StatelessWidget {
  const SecondaryBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white05,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.white10,
          width: 1.0,
        ),
      ),
      child: child,
    );
  }
}