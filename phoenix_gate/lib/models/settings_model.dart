import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';

class SettingsModel extends ChangeNotifier {
  static const _kBackgroundColorKey = 'background_color';
  static const _kFontColorKey = 'font_color';
  static const _kHighlightColorKey = 'highlight_color';
  static const _kButtonColorKey = 'button_color';
  static const _kCustomLogoImageKey = 'custom_logo_image_base64';
  static const _kMembershipImageKey = 'membership_image_base64';

  Color _backgroundColor = AppColors.backgroundPrimary;
  Color _fontColor = AppColors.font;
  Color _highlightColor = AppColors.fontHighlight;
  Color _buttonColor = AppColors.buttons;
  String? _customLogoImageBase64;
  String? _membershipImageBase64;

  SettingsModel() {
    _load();
  }

  Color get backgroundColor => _backgroundColor;
  Color get fontColor => _fontColor;
  Color get highlightColor => _highlightColor;
  Color get buttonColor => _buttonColor;
  String? get customLogoImageBase64 => _customLogoImageBase64;
  String? get membershipImageBase64 => _membershipImageBase64;

  static String colorToHex(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
  }

  static Color? tryParseHexColor(String input) {
    final normalized = input.trim().replaceFirst('#', '').toUpperCase();
    final isValid = RegExp(r'^[0-9A-F]{6}([0-9A-F]{2})?$').hasMatch(normalized);
    if (!isValid) return null;

    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    return Color(int.parse(hex, radix: 16));
  }

  static Uint8List? decodeImageBytes(String? base64Data) {
    if (base64Data == null || base64Data.isEmpty) return null;
    try {
      return base64Decode(base64Data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _backgroundColor = Color(
        prefs.getInt(_kBackgroundColorKey) ??
            AppColors.backgroundPrimary.toARGB32(),
      );
      _fontColor = Color(
        prefs.getInt(_kFontColorKey) ?? AppColors.font.toARGB32(),
      );
      _highlightColor = Color(
        prefs.getInt(_kHighlightColorKey) ?? AppColors.fontHighlight.toARGB32(),
      );
      _buttonColor = Color(
        prefs.getInt(_kButtonColorKey) ?? AppColors.buttons.toARGB32(),
      );
      _customLogoImageBase64 = prefs.getString(_kCustomLogoImageKey);
      _membershipImageBase64 = prefs.getString(_kMembershipImageKey);
      notifyListeners();
    } catch (_) {
      // ignore errors and keep default
    }
  }

  Future<void> setBackgroundColor(Color color) async {
    _backgroundColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kBackgroundColorKey, color.toARGB32());
    } catch (_) {
      // ignore persistence errors
    }
  }

  Future<void> setFontColor(Color color) async {
    _fontColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kFontColorKey, color.toARGB32());
    } catch (_) {
      // ignore persistence errors
    }
  }

  Future<void> setHighlightColor(Color color) async {
    _highlightColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kHighlightColorKey, color.toARGB32());
    } catch (_) {
      // ignore persistence errors
    }
  }

  Future<void> setButtonColor(Color color) async {
    _buttonColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kButtonColorKey, color.toARGB32());
    } catch (_) {
      // ignore persistence errors
    }
  }

  Future<void> setCustomLogoImageBase64(String? base64Image) async {
    _customLogoImageBase64 = base64Image;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (base64Image == null || base64Image.isEmpty) {
        await prefs.remove(_kCustomLogoImageKey);
      } else {
        await prefs.setString(_kCustomLogoImageKey, base64Image);
      }
    } catch (_) {
      // ignore persistence errors
    }
  }

  Future<void> setMembershipImageBase64(String? base64Image) async {
    _membershipImageBase64 = base64Image;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (base64Image == null || base64Image.isEmpty) {
        await prefs.remove(_kMembershipImageKey);
      } else {
        await prefs.setString(_kMembershipImageKey, base64Image);
      }
    } catch (_) {
      // ignore persistence errors
    }
  }
}
