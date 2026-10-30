import 'package:flutter/material.dart';

import '../../../../../../config/theme/app_theme.dart';

/// A titled group of rows in the stock item form: a small bold title in
/// [AppColors.primary] with a thin divider underneath, followed by [children].
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Divider(color: AppColors.border, height: 12),
          ...children,
        ],
      ),
    );
  }
}
