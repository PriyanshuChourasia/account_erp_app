import 'package:flutter/material.dart';

import '../../../../../../config/theme/app_theme.dart';

/// A single `Label : value` row of the stock item form.
///
/// The label sits in a fixed-width column followed by a `:` separator, and
/// [child] (usually a dense input) fills the remaining width.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.labelWidth = 160,
  });

  final String label;
  final Widget child;
  final bool isRequired;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text.rich(
                TextSpan(
                  text: label,
                  children: [
                    if (isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                style: labelStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 12),
            child: Text(':', style: labelStyle),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
