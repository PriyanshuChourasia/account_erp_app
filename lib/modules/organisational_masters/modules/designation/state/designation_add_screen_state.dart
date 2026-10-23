import 'package:flutter/material.dart';

import '../models/create_designation_request.dart';
import '../screens/designation_add_screen.dart';
import '../widgets/designation_add_dialog.dart';

/// State for [DesignationAddScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class DesignationAddScreenState extends State<DesignationAddScreen> {
  Future<void> _openAddDialog() async {
    final result = await showDialog<CreateDesignationRequest>(
      context: context,
      builder: (_) => const DesignationAddDialog(),
    );
    if (result == null || !mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add designation'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: FilledButton.icon(
          onPressed: _openAddDialog,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add designation'),
        ),
      ),
    );
  }
}
