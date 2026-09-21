import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../application_module/models/application_module.dart';
import '../../application_module/viewModel/application_module_view_model.dart';
import '../models/application_feature.dart';
import '../models/create_application_feature_request.dart';
import '../screens/application_feature_add_screen.dart';
import '../viewModel/application_feature_view_model.dart';
import '../widgets/application_feature_card.dart';

/// One draft feature being filled in on the multi-add form.
class _FeatureDraft {
  final nameController = TextEditingController();
  final endPointController = TextEditingController();
  final descriptionController = TextEditingController();
  ApiMethod apiMethod = ApiMethod.get;
  ApiDeviceType apiDeviceType = ApiDeviceType.all;
  bool active = true;

  void dispose() {
    nameController.dispose();
    endPointController.dispose();
    descriptionController.dispose();
  }
}

/// State for [ApplicationFeatureAddScreen]. Kept out of the screen file to
/// follow the StatefulWidget split pattern.
///
/// Layout: the left grid is a module picker (search + select). Selecting a
/// module loads its features — if the module already has features they are
/// shown as detail cards; otherwise a multi-feature create form appears so
/// several features can be added at once.
class ApplicationFeatureAddScreenState
    extends State<ApplicationFeatureAddScreen> {
  static const double _wideBreakpoint = 760;

  final _moduleQueryController = TextEditingController();
  ApplicationModule? _selectedModule;
  bool _showModuleList = false;
  bool _showCreateForm = false;
  List<_FeatureDraft> _featureDrafts = [_FeatureDraft()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final moduleViewModel = context.read<ApplicationModuleViewModel>();
      if (moduleViewModel.applicationModules.isEmpty) {
        moduleViewModel.loadApplicationModules();
      }
    });
  }

  @override
  void dispose() {
    _moduleQueryController.dispose();
    for (final draft in _featureDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  /// Tapping the already-selected module in the list deselects it; tapping
  /// any other module selects it.
  void _toggleModule(ApplicationModule module) {
    if (_selectedModule?.id == module.id) {
      _deselectModule();
    } else {
      _selectModule(module);
    }
  }

  void _selectModule(ApplicationModule module) {
    setState(() {
      _selectedModule = module;
      _showModuleList = false;
      _showCreateForm = false;
      for (final draft in _featureDrafts) {
        _prefillEndpointPrefix(draft, module);
      }
    });
    final featureViewModel = context.read<ApplicationFeatureViewModel>();
    if (featureViewModel.applicationFeatures.isEmpty) {
      featureViewModel.loadApplicationFeatures();
    }
  }

  void _deselectModule() {
    setState(() {
      _selectedModule = null;
      _showCreateForm = false;
    });
  }

  /// Seeds a fresh draft's endpoint field with `<module endpoint>/` so the
  /// first thing the user sees when adding a feature is already anchored to
  /// the selected module.
  void _prefillEndpointPrefix(_FeatureDraft draft, ApplicationModule module) {
    if (draft.endPointController.text.isNotEmpty) return;
    final prefix = module.endpoint ?? 'application_modules';
    draft.endPointController.text = '$prefix/';
  }

  void _addDraft() {
    setState(() {
      final draft = _FeatureDraft();
      final module = _selectedModule;
      if (module != null) _prefillEndpointPrefix(draft, module);
      _featureDrafts.add(draft);
    });
  }

  void _removeDraft(int index) {
    setState(() {
      _featureDrafts[index].dispose();
      _featureDrafts.removeAt(index);
    });
  }

  Future<void> _saveFeatures() async {
    final viewModel = context.read<ApplicationFeatureViewModel>();
    final module = _selectedModule;
    if (module == null) return;
    final validDrafts = [
      for (final draft in _featureDrafts)
        if (draft.nameController.text.trim().isNotEmpty &&
            draft.endPointController.text.trim().isNotEmpty)
          CreateApplicationFeatureRequest(
            name: draft.nameController.text.trim(),
            apiMethod: draft.apiMethod,
            apiDeviceType: draft.apiDeviceType,
            endPoint: _normalizedEndpoint(draft.endPointController.text),
            description: draft.descriptionController.text.trim().isEmpty
                ? null
                : draft.descriptionController.text.trim(),
            active: draft.active,
          ),
    ];
    if (validDrafts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in at least one feature.')),
      );
      return;
    }
    for (final request in validDrafts) {
      await viewModel.addApplicationFeature(request);
    }
    if (!mounted) return;
    setState(() {
      _showCreateForm = false;
      final draft = _FeatureDraft();
      _prefillEndpointPrefix(draft, module);
      _featureDrafts = [draft];
    });
  }

  /// Ensures the saved endpoint starts with exactly one leading slash. The
  /// module prefix is already part of [rawEndpoint] since it's seeded into
  /// the field by [_prefillEndpointPrefix].
  String _normalizedEndpoint(String rawEndpoint) {
    final trimmed = rawEndpoint.trim();
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }

  Future<void> _deleteFeature(String id) async {
    await context.read<ApplicationFeatureViewModel>().deleteApplicationFeature(
      id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final moduleViewModel = context.watch<ApplicationModuleViewModel>();
    final featureViewModel = context.watch<ApplicationFeatureViewModel>();
    final modules = moduleViewModel.filteredApplicationModules;
    final module = _selectedModule;
    final moduleFeatures = module == null
        ? const <ApplicationFeature>[]
        : featureViewModel.applicationFeatures
              .where((feature) => feature.moduleId == module.id)
              .toList();
    final showCards =
        module != null && moduleFeatures.isNotEmpty && !_showCreateForm;

    final modulePicker = _ModulePickerGrid(
      modules: modules,
      queryController: _moduleQueryController,
      selectedModule: _selectedModule,
      showList: _showModuleList,
      onOpenList: () {
        if (!_showModuleList) setState(() => _showModuleList = true);
      },
      onQueryChanged: (value) =>
          context.read<ApplicationModuleViewModel>().setQuery(value),
      onModuleSelected: _toggleModule,
      onClearSelection: _deselectModule,
    );

    final Widget right;
    if (module == null) {
      right = const _EmptyPanel(
        icon: Icons.widgets_rounded,
        title: 'Select a module',
        subtitle: 'Its features will appear here, or you can create new ones.',
      );
    } else if (showCards) {
      right = _ModuleFeaturesPanel(
        features: moduleFeatures,
        onAddFeature: () => setState(() => _showCreateForm = true),
        onDelete: _deleteFeature,
      );
    } else {
      right = _MultiFeaturePanel(
        drafts: _featureDrafts,
        onAddDraft: _addDraft,
        onRemoveDraft: _removeDraft,
        onSave: _saveFeatures,
        onCancel: moduleFeatures.isEmpty
            ? null
            : () => setState(() => _showCreateForm = false),
        saving: featureViewModel.isLoading,
      );
    }

    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add application feature'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _CompactFormTheme(
          child: isWide
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 640, child: modulePicker),
                      const SizedBox(width: 16),
                      Expanded(child: right),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [modulePicker, const SizedBox(height: 16), right],
                ),
        ),
      ),
    );
  }
}

/// Shrinks field and text sizing for the whole form: dense input
/// decoration, smaller icons, and a slightly reduced text scale.
class _CompactFormTheme extends StatelessWidget {
  const _CompactFormTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontSizeFactor: 0.9),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
      child: IconTheme.merge(data: const IconThemeData(size: 18), child: child),
    );
  }
}

class _GridPanel extends StatelessWidget {
  const _GridPanel({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// Left grid: a real search box that opens a real select list of modules
/// when tapped — the list stays closed until then.
class _ModulePickerGrid extends StatelessWidget {
  const _ModulePickerGrid({
    required this.modules,
    required this.queryController,
    required this.selectedModule,
    required this.showList,
    required this.onOpenList,
    required this.onQueryChanged,
    required this.onModuleSelected,
    required this.onClearSelection,
  });

  final List<ApplicationModule> modules;
  final TextEditingController queryController;
  final ApplicationModule? selectedModule;
  final bool showList;
  final VoidCallback onOpenList;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ApplicationModule> onModuleSelected;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    return _GridPanel(
      title: 'Select Module',
      icon: Icons.widgets_rounded,
      children: [
        TextField(
          controller: queryController,
          onTap: onOpenList,
          onChanged: (value) {
            onOpenList();
            onQueryChanged(value);
          },
          decoration: const InputDecoration(
            hintText: 'Search modules...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        if (selectedModule != null) ...[
          const SizedBox(height: 12),
          _ModuleSummary(module: selectedModule!, onClear: onClearSelection),
        ],
        if (showList) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 320,
              child: modules.isEmpty
                  ? const Center(
                      child: Text(
                        'No modules found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: modules.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        final isSelected = module.id == selectedModule?.id;
                        return InkWell(
                          onTap: () => onModuleSelected(module),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: module.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    module.icon,
                                    color: module.color,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    module.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  size: 20,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Full detail card for the selected module — every field it carries,
/// shown here in the left grid so nothing needs to jump to the right panel.
class _ModuleSummary extends StatelessWidget {
  const _ModuleSummary({required this.module, required this.onClear});

  final ApplicationModule module;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: module.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: module.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(module.icon, color: module.color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  module.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Clear selection',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 16),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SummaryRow(label: 'ID', value: module.id),
          _SummaryRow(label: 'Code', value: module.code ?? '—'),
          _SummaryRow(label: 'Endpoint', value: module.endpoint ?? '—'),
          _SummaryRow(label: 'Description', value: module.description ?? '—'),
          _SummaryRow(
            label: 'Version',
            value: module.version?.toString() ?? '—',
          ),
          _SummaryRow(
            label: 'System module',
            value: module.isSystem ? 'Yes' : 'No',
          ),
          _SummaryRow(label: 'Active', value: module.active ? 'Yes' : 'No'),
        ],
      ),
    );
  }
}

/// One label/value line inside [_ModuleSummary].
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shown before a module is chosen.
class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 44,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Right grid: shows the selected module's existing features as detail cards.
class _ModuleFeaturesPanel extends StatelessWidget {
  const _ModuleFeaturesPanel({
    required this.features,
    required this.onAddFeature,
    required this.onDelete,
  });

  final List<ApplicationFeature> features;
  final VoidCallback onAddFeature;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Module Features (${features.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: onAddFeature,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add feature'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) => ApplicationFeatureCard(
            feature: features[index],
            onDelete: () => onDelete(features[index].id),
          ),
        ),
      ],
    );
  }
}

/// Right grid: multi-feature create form. Add as many features as needed in
/// one go.
class _MultiFeaturePanel extends StatelessWidget {
  const _MultiFeaturePanel({
    required this.drafts,
    required this.onAddDraft,
    required this.onRemoveDraft,
    required this.onSave,
    required this.onCancel,
    required this.saving,
  });

  final List<_FeatureDraft> drafts;
  final VoidCallback onAddDraft;
  final ValueChanged<int> onRemoveDraft;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < drafts.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == drafts.length - 1 ? 0 : 12),
            child: _FeatureDraftCard(
              index: i,
              draft: drafts[i],
              showRemove: drafts.length > 1,
              onRemove: () => onRemoveDraft(i),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onAddDraft,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add another feature'),
            ),
            const Spacer(),
            if (onCancel != null)
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: const Icon(Icons.check_rounded, size: 16),
              label: Text(saving ? 'Saving...' : 'Save all'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Create multiple features at once for this module.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// One feature entry inside the multi-add form.
class _FeatureDraftCard extends StatefulWidget {
  const _FeatureDraftCard({
    required this.index,
    required this.draft,
    required this.showRemove,
    required this.onRemove,
  });

  final int index;
  final _FeatureDraft draft;
  final bool showRemove;
  final VoidCallback onRemove;

  @override
  State<_FeatureDraftCard> createState() => _FeatureDraftCardState();
}

class _FeatureDraftCardState extends State<_FeatureDraftCard> {
  _FeatureDraft get draft => widget.draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.index + 1}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Feature ${widget.index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.showRemove)
                IconButton(
                  tooltip: 'Remove feature',
                  onPressed: widget.onRemove,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: draft.nameController,
            decoration: const InputDecoration(
              labelText: 'Name *',
              hintText: 'e.g. Account Nature',
              prefixIcon: Icon(Icons.extension_rounded),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<ApiMethod>(
                  initialValue: draft.apiMethod,
                  decoration: const InputDecoration(
                    labelText: 'API method',
                    prefixIcon: Icon(Icons.http_rounded),
                  ),
                  items: [
                    for (final method in ApiMethod.values)
                      DropdownMenuItem(
                        value: method,
                        child: Text(method.name.toUpperCase()),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => draft.apiMethod = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<ApiDeviceType>(
                  initialValue: draft.apiDeviceType,
                  decoration: const InputDecoration(
                    labelText: 'Device type',
                    prefixIcon: Icon(Icons.devices_rounded),
                  ),
                  items: [
                    for (final deviceType in ApiDeviceType.values)
                      DropdownMenuItem(
                        value: deviceType,
                        child: Text(deviceType.name.toUpperCase()),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => draft.apiDeviceType = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: draft.endPointController,
            decoration: const InputDecoration(
              labelText: 'Endpoint *',
              hintText: 'e.g. accounting-masters/account_natures',
              prefixIcon: Icon(Icons.link_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: draft.descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: draft.active,
              onChanged: (value) => setState(() => draft.active = value),
            ),
          ),
        ],
      ),
    );
  }
}
