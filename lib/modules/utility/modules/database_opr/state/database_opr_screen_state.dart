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
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.6,
                  children: [
                    _OprCard(
                      title: 'Backup',
                      subtitle: 'Create a database backup',
                      icon: Icons.backup_rounded,
                      color: Color(0xFF059669),
                    ),
                    _OprCard(
                      title: 'Restore',
                      subtitle: 'Restore from a backup file',
                      icon: Icons.restore_rounded,
                      color: Color(0xFFD97706),
                    ),
                    _OprCard(
                      title: 'Migrate',
                      subtitle: 'Run database migrations',
                      icon: Icons.sync_alt_rounded,
                      color: Color(0xFF7C3AED),
                    ),
                    _OprCard(
                      title: 'Optimize',
                      subtitle: 'Optimize database tables',
                      icon: Icons.speed_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    _OprCard(
                      title: 'API Operations',
                      subtitle: 'Inspect and test backend API',
                      icon: Icons.api_rounded,
                      color: Color(0xFF0EA5E9),
                      onTap: _openApiOperation,
                    ),
                  ],
                ),
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
}

class _OprCard extends StatelessWidget {
  const _OprCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title — coming soon')),
              );
            },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}