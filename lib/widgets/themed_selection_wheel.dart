import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A themed, finite Cupertino wheel whose controller is owned by its caller.
class ThemedSelectionWheel extends StatelessWidget {
  const ThemedSelectionWheel({
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
    this.itemExtent = 56,
    this.height = 224,
    super.key,
  }) : assert(itemCount > 0),
       assert(itemExtent > 0),
       assert(height > 0);

  final FixedExtentScrollController controller;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int> onSelectedItemChanged;
  final double itemExtent;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: CupertinoPicker.builder(
        scrollController: controller,
        itemExtent: itemExtent,
        childCount: itemCount,
        useMagnifier: true,
        magnification: 1.08,
        squeeze: 1.05,
        onSelectedItemChanged: onSelectedItemChanged,
        selectionOverlay: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.06),
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: colors.primary.withValues(alpha: 0.78),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
