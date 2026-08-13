import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_voucher_type_request.dart';
import '../models/voucher_type.dart';
import '../screens/voucher_type_screen.dart';
import '../viewModel/voucher_type_view_model.dart';
import '../widgets/voucher_type_add_dialog.dart';
import '../widgets/voucher_type_card.dart';

/// State for [VoucherTypeScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class VoucherTypeScreenState extends State<VoucherTypeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<VoucherTypeViewModel>().loadVoucherTypes();
    });
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<CreateVoucherTypeRequest>(
      context: context,
      builder: (_) => const VoucherTypeAddDialog(),
    );
    if (result == null || !mounted) return;
    await context.read<VoucherTypeViewModel>().addVoucherType(result);
  }

  Future<void> _confirmDelete(
    VoucherTypeViewModel viewModel,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete voucher type?'),
        content: const Text(
          'This will remove the voucher type from your master.',
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
    if (confirmed == true) await viewModel.deleteVoucherType(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VoucherTypeViewModel>();
    final voucherTypes = viewModel.filteredVoucherTypes;

    return Scaffold(
      appBar: AppBar(title: const Text('Voucher Types')),
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
                        hintText: 'Search by name, code or ID...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _openAddDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add voucher type'),
                  ),
                ],
              ),
              if (viewModel.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.08),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
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
                    : voucherTypes.isEmpty
                        ? const _EmptyState()
                        : LayoutBuilder(
                            builder: (context, constraints) =>
                                constraints.maxWidth >= 720
                                    ? _VoucherTypeTable(
                                        voucherTypes: voucherTypes,
                                      )
                                    : ListView.separated(
                                        itemCount: voucherTypes.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final voucherType = voucherTypes[index];
                                          return VoucherTypeCard(
                                            voucherType: voucherType,
                                            onDelete: () => _confirmDelete(
                                                viewModel, voucherType.id),
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

/// Table view of voucher types for wide screens.
///
/// Built from flex-aligned rows instead of [DataTable] so it fills the
/// available width, scrolls vertically when the list is long (with a header
/// that stays pinned), and can reuse the same icon/color treatment as
/// [VoucherTypeCard]. Rows are read-only — deleting only happens from the card
/// view.
class _VoucherTypeTable extends StatelessWidget {
  const _VoucherTypeTable({required this.voucherTypes});

  static const _slNoColumnWidth = 56.0;
  static const _codeColumnWidth = 96.0;

  final List<VoucherType> voucherTypes;

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
          const _VoucherTypeTableHeader(
            slNoColumnWidth: _slNoColumnWidth,
            codeColumnWidth: _codeColumnWidth,
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: voucherTypes.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) => _VoucherTypeTableRow(
                slNo: index + 1,
                voucherType: voucherTypes[index],
                zebra: index.isOdd,
                slNoColumnWidth: _slNoColumnWidth,
                codeColumnWidth: _codeColumnWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherTypeTableHeader extends StatelessWidget {
  const _VoucherTypeTableHeader({
    required this.slNoColumnWidth,
    required this.codeColumnWidth,
  });

  final double slNoColumnWidth;
  final double codeColumnWidth;

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
          Expanded(flex: 3, child: Text('NAME', style: labelStyle)),
          SizedBox(
            width: codeColumnWidth,
            child: Text('CODE', style: labelStyle, textAlign: TextAlign.center),
          ),
          Expanded(flex: 4, child: Text('DESCRIPTION', style: labelStyle)),
        ],
      ),
    );
  }
}

class _VoucherTypeTableRow extends StatelessWidget {
  const _VoucherTypeTableRow({
    required this.slNo,
    required this.voucherType,
    required this.zebra,
    required this.slNoColumnWidth,
    required this.codeColumnWidth,
  });

  final int slNo;
  final VoucherType voucherType;
  final bool zebra;
  final double slNoColumnWidth;
  final double codeColumnWidth;

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
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              voucherType.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: codeColumnWidth,
            child: Align(
              alignment: Alignment.center,
              child: voucherType.code == null
                  ? Text(
                      '—',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        voucherType.code!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              voucherType.description ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
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
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No voucher types found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add a new voucher type.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
