import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';
import 'isometric_illustration.dart';

/// A single feature highlight shown below the illustration.
class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// Left-side panel that showcases the app's key features.
///
/// On wide screens this occupies the left half of the auth layout.
/// Displays the isometric workflow illustration as the hero visual,
/// with feature highlights listed below.
class FeaturesPanel extends StatelessWidget {
  const FeaturesPanel({super.key});

  static const List<_FeatureItem> _features = [
    _FeatureItem(
      icon: Icons.account_balance_rounded,
      title: 'Accounting Masters',
      description: 'Manage account groups, ledgers, and financial data.',
    ),
    _FeatureItem(
      icon: Icons.inventory_2_rounded,
      title: 'Inventory Management',
      description: 'Track stock groups, categories, items, and units.',
    ),
    _FeatureItem(
      icon: Icons.business_rounded,
      title: 'Organisational Setup',
      description: 'Configure financial years, countries, and states.',
    ),
    _FeatureItem(
      icon: Icons.receipt_long_rounded,
      title: 'Voucher Types',
      description: 'Define voucher types for all transactions.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.gradientBlue,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Brand header ──
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Account ERP',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Accounts and Inventory process made simple',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 20),

              // ── Isometric illustration ──
              Expanded(
                flex: 5,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: IsometricIllustration(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Feature highlights ──
              Expanded(
                flex: 4,
                child: ListView.separated(
                  itemCount: _features.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final feature = _features[index];
                    return _FeatureRow(feature: feature);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single compact feature row inside [FeaturesPanel].
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});

  final _FeatureItem feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.2,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
