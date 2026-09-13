import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../config/token_storage.dart';
import '../../../../../../../config/theme/app_theme.dart';
import '../../../../../../../modules/developer_masters/modules/application_feature/models/application_feature.dart' show ApplicationFeature;
import '../../../../../../../modules/developer_masters/modules/application_feature/viewModel/application_feature_view_model.dart';
import '../../../../../../../modules/developer_masters/modules/application_module/models/application_module.dart';
import '../../../../../../../modules/developer_masters/modules/application_module/viewModel/application_module_view_model.dart';
import '../../../../../../../network/service_locator.dart';
import '../models/api_method.dart';
import '../screens/api_operation_screen.dart';

/// State for [ApiOperationScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class ApiOperationScreenState extends State<ApiOperationScreen> {
  static const _quadrants = [
    (
      title: 'Test Endpoint',
      subtitle: 'Send a sample request',
      icon: Icons.science_rounded,
    ),
    (
      title: 'Request Logs',
      subtitle: 'Review recent API calls',
      icon: Icons.list_alt_rounded,
    ),
    (
      title: 'Rate Limits',
      subtitle: 'Check usage against limits',
      icon: Icons.speed_rounded,
    ),
  ];

  String? _selectedModule;
  ApiMethod _selectedMethod = ApiMethod.get;
  List<ApplicationFeature> _moduleFeatures = const [];
  final TextEditingController _keyController = TextEditingController(
    text: 'Authorization',
  );
  final TextEditingController _valueController = TextEditingController(
    text: 'token',
  );

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await globalService<TokenStorage>().getToken();
    if (!mounted) return;
    _valueController.text = token ?? '';
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _sendFor(String module) async {
    final token = await globalService<TokenStorage>().getToken() ?? '';
    if (!mounted) return;
    _valueController.text = token;
    final feature = _moduleFeatures.isEmpty ? null : _moduleFeatures.first;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: feature == null
            ? Theme.of(context).colorScheme.error
            : null,
        content: Text(
          feature == null
              ? 'No API available to test for $module.'
              : '$module — ${feature.apiMethod.name.toUpperCase()} '
                    '${feature.endPoint} (Send coming soon).',
        ),
      ),
    );
  }

  Widget _buildApiHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<ApiMethod>(
              initialValue: _selectedMethod,
              isDense: true,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Method',
                prefixIcon: Icon(Icons.http_rounded, size: 16),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
              ),
              items: [
                for (final method in ApiMethod.values)
                  DropdownMenuItem(
                    value: method,
                    child: Text(method.wireValue),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _selectedMethod = value ?? ApiMethod.get),
            ),
          ),
          const SizedBox(width: 6),
          _buildSearchSelectCell(),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _selectedModule == null
                    ? null
                    : () => _sendFor(_selectedModule!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 14),
                label: const Text('Send'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSelectCell() {
    final theme = Theme.of(context);
    return Expanded(
      flex: 6,
      child: InkWell(
        onTap: _pickModule,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.widgets_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _selectedModule ?? 'Select…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _selectedModule == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontWeight: _selectedModule == null
                        ? FontWeight.w400
                        : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickModule() async {
    final viewModel = context.read<ApplicationModuleViewModel>();
    if (viewModel.applicationModules.isEmpty && !viewModel.isLoading) {
      await viewModel.loadApplicationModules();
      if (!mounted) return;
    }
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _SearchSelectSheet(
        items: [
          for (final module in viewModel.applicationModules) module.name,
        ],
      ),
    );
    if (result == null || !mounted) return;

    ApplicationModule? module;
    for (final candidate in viewModel.applicationModules) {
      if (candidate.name == result) module = candidate;
    }

    setState(() {
      _selectedModule = result;
      _moduleFeatures = const [];
    });
    if (module != null) await _loadModuleFeatures(module);
  }

  Future<void> _loadModuleFeatures(ApplicationModule module) async {
    final featureViewModel = context.read<ApplicationFeatureViewModel>();
    await featureViewModel.loadApplicationFeatures();
    if (!mounted) return;

    final features = featureViewModel.applicationFeatures
        .where(
          (feature) => feature.moduleId != null && feature.moduleId == module.id,
        )
        .toList();

    setState(() => _moduleFeatures = features);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: features.isEmpty
            ? Theme.of(context).colorScheme.error
            : null,
        content: Text(
          features.isEmpty
              ? 'No API available to test for ${module.name}.'
              : '${module.name}: ${features.length} API(s) available to test.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('API Operations')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Management',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Inspect and exercise the backend API.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildSelectModule(),
                          const SizedBox(width: 4),
                          _buildQuadrant(0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Row(
                        children: [
                          _buildQuadrant(1),
                          const SizedBox(width: 4),
                          _buildQuadrant(2),
                        ],
                      ),
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

  Widget _buildSelectModule() {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Module',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildApiHeader(),
            const SizedBox(height: 8),
            _buildKeyValueHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValueHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _keyController,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Key',
                prefixIcon: Icon(Icons.key_rounded, size: 16),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _valueController,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Value',
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 16),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrant(int index) {
    final q = _quadrants[index];
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${q.title} — coming soon')),
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(q.icon, size: 20, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(
                q.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                q.subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Searchable picker shown as a modal bottom sheet by `_buildSearchSelectCell`.
class _SearchSelectSheet extends StatefulWidget {
  const _SearchSelectSheet({required this.items});

  final List<String> items;

  @override
  State<_SearchSelectSheet> createState() => _SearchSelectSheetState();
}

class _SearchSelectSheetState extends State<_SearchSelectSheet> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  List<String> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items.where((e) => e.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search…',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final item = _filtered[index];
                  return ListTile(
                    dense: true,
                    title: Text(item),
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}