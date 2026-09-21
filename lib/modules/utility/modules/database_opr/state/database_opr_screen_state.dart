import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../modules/api_operation/screens/api_operation_screen.dart';
import '../screens/database_opr_screen.dart';

/// State for [DatabaseOprScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class DatabaseOprScreenState extends State<DatabaseOprScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Database Operations')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Database Management',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tools to manage and maintain your database.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _OprButton(
                    label: 'Backup',
                    icon: Icons.backup_rounded,
                    color: Color(0xFF059669),
                    onTap: () => _comingSoon('Backup'),
                  ),
                  _OprButton(
                    label: 'Restore',
                    icon: Icons.restore_rounded,
                    color: Color(0xFFD97706),
                    onTap: () => _comingSoon('Restore'),
                  ),
                  _OprButton(
                    label: 'Migrate',
                    icon: Icons.sync_alt_rounded,
                    color: Color(0xFF7C3AED),
                    onTap: () => _comingSoon('Migrate'),
                  ),
                  _OprButton(
                    label: 'Optimize',
                    icon: Icons.speed_rounded,
                    color: Color(0xFF2563EB),
                    onTap: () => _comingSoon('Optimize'),
                  ),
                  _OprButton(
                    label: 'API Ops',
                    icon: Icons.api_rounded,
                    color: Color(0xFF0EA5E9),
                    onTap: _openApiOperation,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openApiOperation() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ApiOperationScreen()),
    );
  }

  void _comingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title — coming soon')),
    );
  }
}

class _OprButton extends StatelessWidget {
  const _OprButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 15),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}