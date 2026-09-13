import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/application_feature.dart';
import '../models/create_application_feature_request.dart';
import '../screens/application_feature_screen.dart';
import '../viewModel/application_feature_view_model.dart';
import '../widgets/application_feature_add_dialog.dart';
import '../widgets/application_feature_card.dart';

/// State for [ApplicationFeatureScreen]. Kept out of the screen file to
/// follow the StatefulWidget split pattern.
class ApplicationFeatureScreenState extends State<ApplicationFeatureScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ApplicationFeatureViewModel>().loadApplicationFeatures();
      }
    });
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<CreateApplicationFeatureRequest>(
      context: context,
      builder: (_) => const ApplicationFeatureAddDialog(),
    );
    if (result == null || !mounted) return;
    await context.read<ApplicationFeatureViewModel>().addApplicationFeature(
      result,
    );
  }

  Future<void> _confirmDelete(
    ApplicationFeatureViewModel viewModel,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete feature?'),
        content: const Text(
          'This will remove the application feature from your master.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await viewModel.deleteApplicationFeature(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplicationFeatureViewModel>();
    final features = viewModel.filteredApplicationFeatures;

    return Scaffold(
      appBar: AppBar(title: const Text('Application Features')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: viewModel.setQuery,
                      decoration: const InputDecoration(
                        hintText: 'Search by name or endpoint...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _openAddDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add feature'),
                  ),
                ],
              ),
              if (viewModel.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          viewModel.error!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : features.isEmpty
                    ? const _EmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 720
                            ? _FeatureTable(
                                features: features,
                                onDelete: (id) =>
                                    _confirmDelete(viewModel, id),
                              )
                            : ListView.separated(
                                itemCount: features.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final feature = features[index];
                                  return ApplicationFeatureCard(
                                    feature: feature,
                                    onDelete: () =>
                                        _confirmDelete(viewModel, feature.id),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Table view of application features for wide screens.
///
/// Built from flex-aligned rows instead of [DataTable] so it fills the
/// available width, scrolls vertically when the list is long (with a header
/// that stays pinned), and can reuse the same icon/color treatment as
/// [ApplicationFeatureCard].
class _FeatureTable extends StatelessWidget {
  const _FeatureTable({required this.features, required this.onDelete});

  static const _slNoColumnWidth = 56.0;
  static const _methodColumnWidth = 90.0;
  static const _statusColumnWidth = 90.0;
  static const _actionsColumnWidth = 56.0;

  final List<ApplicationFeature> features;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _FeatureTableHeader(
            slNoColumnWidth: _slNoColumnWidth,
            methodColumnWidth: _methodColumnWidth,
            statusColumnWidth: _statusColumnWidth,
            actionsColumnWidth: _actionsColumnWidth,
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: features.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) => _FeatureTableRow(
                slNo: index + 1,
                feature: features[index],
                zebra: index.isOdd,
                slNoColumnWidth: _slNoColumnWidth,
                methodColumnWidth: _methodColumnWidth,
                statusColumnWidth: _statusColumnWidth,
                actionsColumnWidth: _actionsColumnWidth,
                onDelete: () => onDelete(features[index].id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTableHeader extends StatelessWidget {
  const _FeatureTableHeader({
    required this.slNoColumnWidth,
    required this.methodColumnWidth,
    required this.statusColumnWidth,
    required this.actionsColumnWidth,
  });

  final double slNoColumnWidth;
  final double methodColumnWidth;
  final double statusColumnWidth;
  final double actionsColumnWidth;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          SizedBox(
            width: slNoColumnWidth,
            child: Text('SL NO', style: labelStyle),
          ),
          Expanded(flex: 2, child: Text('NAME', style: labelStyle)),
          SizedBox(
            width: methodColumnWidth,
            child: Text(
              'METHOD',
              style: labelStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(flex: 2, child: Text('ENDPOINT', style: labelStyle)),
          Expanded(flex: 3, child: Text('DESCRIPTION', style: labelStyle)),
          SizedBox(
            width: statusColumnWidth,
            child: Text(
              'STATUS',
              style: labelStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: actionsColumnWidth),
        ],
      ),
    );
  }
}

class _FeatureTableRow extends StatelessWidget {
  const _FeatureTableRow({
    required this.slNo,
    required this.feature,
    required this.zebra,
    required this.slNoColumnWidth,
    required this.methodColumnWidth,
    required this.statusColumnWidth,
    required this.actionsColumnWidth,
    required this.onDelete,
  });

  final int slNo;
  final ApplicationFeature feature;
  final bool zebra;
  final double slNoColumnWidth;
  final double methodColumnWidth;
  final double statusColumnWidth;
  final double actionsColumnWidth;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: zebra ? AppColors.background.withValues(alpha: 0.4) : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: slNoColumnWidth,
            child: Text(
              '$slNo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              feature.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: methodColumnWidth,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  feature.apiMethod.name.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              feature.endPoint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              feature.description ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: statusColumnWidth,
            child: Align(
              alignment: Alignment.center,
              child: _StatusBadge(active: feature.active),
            ),
          ),
          SizedBox(
            width: actionsColumnWidth,
            child: IconButton(
              tooltip: 'Delete feature',
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? AppColors.gradientGreen.first.withValues(alpha: 0.12)
            : AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: active ? AppColors.gradientGreen.first : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.extension_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No application features found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add a new feature.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
