import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:phonix_scanner/colors.dart';
import 'package:phonix_scanner/models/settings_model.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.isBottomSheet = false});

  final bool isBottomSheet;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _maxImageBytes = 2000 * 1024;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage({
    required Future<void> Function(String? base64Image) onImageSelected,
    required String label,
  }) async {
    try {
      final selected = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (selected == null) return;
      final bytes = await selected.readAsBytes();

      if (!mounted) return;
      if (bytes.length > _maxImageBytes) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image is too large.')));
        return;
      }

      await onImageSelected(base64Encode(bytes));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload $label image.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isBottomSheet)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: settings.fontColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          Text(
            'Brand Settings',
            style: TextStyle(
              color: settings.fontColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Colors',
            style: TextStyle(
              color: settings.highlightColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Column(
            children: [
              _HexColorInputRow(
                label: 'Background',
                color: settings.backgroundColor,
                onColorChanged: settings.setBackgroundColor,
                textColor: settings.fontColor,
                borderColor: settings.highlightColor,
              ),
              const SizedBox(height: 12),
              _HexColorInputRow(
                label: 'Text',
                color: settings.fontColor,
                onColorChanged: settings.setFontColor,
                textColor: settings.fontColor,
                borderColor: settings.highlightColor,
              ),
              const SizedBox(height: 12),
              _HexColorInputRow(
                label: 'Accent',
                color: settings.highlightColor,
                onColorChanged: settings.setHighlightColor,
                textColor: settings.fontColor,
                borderColor: settings.highlightColor,
              ),
              const SizedBox(height: 12),
              _HexColorInputRow(
                label: 'Buttons',
                color: settings.buttonColor,
                onColorChanged: settings.setButtonColor,
                textColor: settings.fontColor,
                borderColor: settings.highlightColor,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Custom logo',
            style: TextStyle(
              color: settings.highlightColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          _UploadBox(
            textColor: settings.fontColor,
            child: _ImageSettingRow(
              textColor: settings.fontColor,
              highlightColor: settings.highlightColor,
              buttonTextColor: settings.backgroundColor,
              imageBytes: SettingsModel.decodeImageBytes(
                settings.customLogoImageBase64,
              ),
              placeholderIcon: Icons.image_outlined,
              onUpload: () => _pickImage(
                onImageSelected: settings.setCustomLogoImageBase64,
                label: 'logo',
              ),
              onReset: settings.customLogoImageBase64 == null
                  ? null
                  : () => settings.setCustomLogoImageBase64(null),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'NFT membership image',
            style: TextStyle(
              color: settings.highlightColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          _UploadBox(
            textColor: settings.fontColor,
            child: _ImageSettingRow(
              textColor: settings.fontColor,
              highlightColor: settings.highlightColor,
              buttonTextColor: settings.backgroundColor,
              imageBytes: SettingsModel.decodeImageBytes(
                settings.membershipImageBase64,
              ),
              placeholderIcon: Icons.verified_outlined,
              onUpload: () => _pickImage(
                onImageSelected: settings.setMembershipImageBase64,
                label: 'membership',
              ),
              onReset: settings.membershipImageBase64 == null
                  ? null
                  : () => settings.setMembershipImageBase64(null),
            ),
          ),
        ],
      ),
    );

    if (widget.isBottomSheet) {
      return Material(
        color: settings.backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: settings.fontColor.withOpacity(0.1),
            width: 1,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: settings.fontColor),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: settings.backgroundColor,
            border: Border.all(
              color: settings.fontColor.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.child, required this.textColor});

  final Widget child;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: textColor.withOpacity(0.18),
        strokeWidth: 1.0,
        dashLength: 6.0,
        gapLength: 4.0,
        radius: 12.0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}

class _HexColorInputRow extends StatefulWidget {
  const _HexColorInputRow({
    required this.label,
    required this.color,
    required this.onColorChanged,
    required this.textColor,
    required this.borderColor,
  });

  final String label;
  final Color color;
  final Future<void> Function(Color color) onColorChanged;
  final Color textColor;
  final Color borderColor;

  @override
  State<_HexColorInputRow> createState() => _HexColorInputRowState();
}

class _HexColorInputRowState extends State<_HexColorInputRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: SettingsModel.colorToHex(widget.color),
    );
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _HexColorInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color.toARGB32() != widget.color.toARGB32() &&
        !_focusNode.hasFocus) {
      _controller.text = SettingsModel.colorToHex(widget.color);
      _errorText = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleInput(String value) {
    final parsed = SettingsModel.tryParseHexColor(value);
    if (parsed == null) {
      setState(() {
        _errorText = 'invalid';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });
    widget.onColorChanged(parsed);
  }

  Future<void> _openColorPicker() async {
    Color selectedColor = widget.color;

    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundPrimary,
          title: Text(
            'Pick ${widget.label.toLowerCase()} color',
            style: TextStyle(color: widget.textColor),
          ),
          content: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(primary: AppColors.fontHighlight),
              inputDecorationTheme: const InputDecorationTheme(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.fontHighlight),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.fontHighlight,
                    width: 0,
                  ),
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: widget.color,
                onColorChanged: (color) => selectedColor = color,
                enableAlpha: false,
                hexInputBar: true,
                portraitOnly: true,
                labelTypes: const [],
                pickerAreaBorderRadius: BorderRadius.circular(12),
                pickerAreaHeightPercent: 0.7,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(selectedColor),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.backgroundPrimary,
                backgroundColor: AppColors.buttons,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
                ),
              ),
              child: const Text('Use color'),
            ),
          ],
        );
      },
    );

    if (pickedColor == null) return;

    setState(() {
      _controller.text = SettingsModel.colorToHex(pickedColor);
      _errorText = null;
    });
    await widget.onColorChanged(pickedColor);
  }

  @override
  Widget build(BuildContext context) {
    final isInvalid = _errorText != null;

    return Row(
      children: [
        Text(
          widget.label,
          style: TextStyle(color: widget.textColor, fontSize: 16),
        ),

        const SizedBox(width: 8),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: _openColorPicker,
            child: Ink(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.color,
                border: Border.all(
                  color: isInvalid
                      ? Colors.red
                      : const Color.fromARGB(77, 255, 255, 255),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          height: 42,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _handleInput,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(color: widget.textColor, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'RRGGBB or AARRGGBB',
              hintStyle: TextStyle(
                color: widget.textColor.withValues(alpha: 0.65),
              ),
              prefixText: '#',
              prefixStyle: TextStyle(color: widget.textColor),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isInvalid
                      ? Colors.red
                      : widget.borderColor.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isInvalid ? Colors.red : widget.borderColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageSettingRow extends StatelessWidget {
  const _ImageSettingRow({
    required this.imageBytes,
    required this.placeholderIcon,
    required this.onUpload,
    required this.onReset,
    required this.textColor,
    required this.highlightColor,
    required this.buttonTextColor,
  });

  final Uint8List? imageBytes;
  final IconData placeholderIcon;
  final VoidCallback onUpload;
  final VoidCallback? onReset;
  final Color textColor;
  final Color highlightColor;
  final Color buttonTextColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (imageBytes != null) ...[
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.white05,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.white20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(imageBytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
        ],

        Icon(
          Icons.file_upload_outlined,
          size: 36,
          color: textColor.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload your image',
          style: TextStyle(color: textColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onUpload,
          style: ElevatedButton.styleFrom(
            foregroundColor: buttonTextColor,
            backgroundColor: highlightColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
            ),
          ),
          child: const Text('Choose file'),
        ),
        if (onReset != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onReset,
            style: TextButton.styleFrom(foregroundColor: textColor),
            child: const Text('Reset to default'),
          ),
        ],
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final drawLength = math.min(dashLength, metric.length - distance);
        final dashPath = metric.extractPath(distance, distance + drawLength);
        canvas.drawPath(dashPath, paint);
        distance += drawLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.radius != radius;
  }
}
