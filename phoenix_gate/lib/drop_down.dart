import 'package:flutter/material.dart';
import 'package:phoenix_gate/colors.dart';
import 'package:phoenix_gate/models/blockchain_networks.dart';
import 'package:provider/provider.dart';
import 'package:phoenix_gate/models/settings_model.dart';


class CustomDropDown extends StatefulWidget {
  const CustomDropDown({
    super.key,
    required this.items,
    required this.onChanged,
    this.selectedValue,
  });

  final List<BlockchainNetworks> items;
  final ValueChanged<BlockchainNetworks> onChanged;
  final BlockchainNetworks? selectedValue;

  @override
  State<StatefulWidget> createState() => CustomDropDownState();
}

class CustomDropDownState extends State<CustomDropDown> {
  final OverlayPortalController _tooltipController = OverlayPortalController();

  final _link = LayerLink();

  /// width of the button after the widget rendered
  double? _buttonWidth;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _tooltipController,
        overlayChildBuilder: (BuildContext context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: MenuWidget(
                width: _buttonWidth,
                items: widget.items,
                selectedValue: widget.selectedValue,
                onItemSelected: (item) {
                  widget.onChanged(item);
                  _tooltipController.hide();
                },
              ),
            ),
          );
        },
        child: ButtonWidget(
          onTap: onTap,
          child: Text(
            widget.selectedValue?.displayName ?? 'Select blockchain',
            style: TextStyle(
              color: widget.selectedValue != null
                  ? Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.black
                  : AppColors.hint,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void onTap() {
    _buttonWidth = context.size?.width;
    _tooltipController.toggle();
  }
}


class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    this.width,
    this.onTap,
    this.child,
  });

  final double? width;

  final VoidCallback? onTap;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.white30,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: AppColors.white30,
            width: 1.0,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: child ?? const SizedBox(),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuWidget extends StatelessWidget {
  const MenuWidget({
    super.key,
    this.width,
    required this.items,
    this.selectedValue,
    required this.onItemSelected,
  });

  final double? width;
  final List<BlockchainNetworks> items;
  final ValueChanged<BlockchainNetworks> onItemSelected;
  final BlockchainNetworks? selectedValue;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    return Container(
      width: width ?? 200,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: ShapeDecoration(
        color: settings.buttonColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.5,
            color: settings.buttonColor.withOpacity(0.9),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 32,
            offset: Offset(0, 20),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(4.0),
        itemCount: items.length,
          itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selectedValue;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                child: Material(
              color: isSelected ? settings.buttonColor.withOpacity(0.85) : settings.buttonColor,
              child: InkWell(
                onTap: () => onItemSelected(item),
                highlightColor: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.displayName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.backgroundPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.backgroundPrimary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}