import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A single calculator key.
///
/// Variations:
/// - [variant] `operator` renders the key on the primary background.
/// - [variant] `function` renders a neutral, secondary key (clear, backspace).
/// - otherwise a plain white key.
///
/// Either [label] (text glyph) or [icon] (Material icon) is displayed; a
/// [expanded] key spans two columns (e.g. the `0` key).
class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.variant = CalculatorButtonVariant.number,
    this.expanded = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final CalculatorButtonVariant variant;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    final Color iconColor;
    switch (variant) {
      case CalculatorButtonVariant.operator:
        background = AppColors.primary;
        foreground = Colors.white;
        iconColor = Colors.white;
      case CalculatorButtonVariant.function:
        background = AppColors.primary.withValues(alpha: 0.08);
        foreground = AppColors.textPrimary;
        iconColor = AppColors.textSecondary;
      case CalculatorButtonVariant.number:
        background = Colors.white;
        foreground = AppColors.textPrimary;
        iconColor = AppColors.textPrimary;
    }

    return Expanded(
      flex: expanded ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: icon != null
                  ? Icon(icon, color: iconColor, size: 22)
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

enum CalculatorButtonVariant { number, operator, function }
