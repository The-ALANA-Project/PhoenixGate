import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';

class InputField extends StatelessWidget {
  final String suggestion;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? errorText;

  const InputField({
    super.key,
    required this.suggestion,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        width: 1.0,
        color: AppColors.white30,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white30,
            hintText: suggestion,
            hintStyle: const TextStyle(color: AppColors.hint),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(width: 1.0, color: AppColors.white),
            ),
            suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 8.0), child: suffix) : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6.0),
          Text(
            errorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 12.0),
          ),
        ],
      ],
    );
  }
}
