import 'package:flutter/material.dart';

import '../models/create_department_request.dart';
import '../screens/department_add_screen.dart';
import '../widgets/department_add_dialog.dart';

/// State for [DepartmentAddScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class DepartmentAddScreenState extends State<DepartmentAddScreen> {
  Future<void> _openAddDialog() async {
    final result = await showDialog<CreateDepartmentRequest>(
      context: context,
      builder: (_) => const DepartmentAddDialog(),
    );
    if (result == null || !mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add department'),
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
          label: const Text('Add department'),
        ),
      ),
    );
  }
}
