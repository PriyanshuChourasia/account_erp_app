import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/handlers/error_handler.dart';
import '../models/create_stock_item_request.dart';
import '../models/stock_item_type.dart';
import '../models/type_of_supply.dart';
import '../screens/stock_item_form_screen.dart';
import '../viewModel/stock_item_view_model.dart';
import '../widgets/stock_item_form/stock_item_form_step_basic_details.dart';
import '../widgets/stock_item_form/stock_item_form_step_classification.dart';
import '../widgets/stock_item_form/stock_item_form_step_identification.dart';
import '../widgets/stock_item_form/stock_item_form_step_pricing.dart';
import '../widgets/stock_item_form/stock_item_form_step_review.dart';
import '../widgets/stock_item_form/stock_item_form_step_stock.dart';
import '../widgets/stock_item_form/stock_item_form_step_tax.dart';

/// State for [StockItemFormScreen]. Owns the multi-step wizard state (current
/// step, per-step validation and save) for the full-screen stock item create
/// form.
class StockItemFormScreenState extends State<StockItemFormScreen> {
  static const int stepCount = 7;

  static const List<String> stepTitles = [
    'Basic details',
    'Classification & units',
    'Tax / GST',
    'Pricing',
    'Stock levels',
    'Identification',
    'Review',
  ];

  int _currentStep = 0;
  bool _isSaving = false;

  final List<GlobalKey<FormState>> _stepFormKeys = List<GlobalKey<FormState>>.generate(
    stepCount,
    (_) => GlobalKey<FormState>(),
  );

  StockItemViewModel get _viewModel => context.read<StockItemViewModel>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(title: const Text('Add stock item')),
      body: Stepper(
        type: width >= 720 ? StepperType.horizontal : StepperType.vertical,
        steps: [
          for (int i = 0; i < stepCount; i++)
            Step(
              title: Text(stepTitles[i]),
              content: _buildStepWidget(i),
            ),
        ],
        currentStep: _currentStep,
        onStepTapped: _goToStep,
        controlsBuilder: (context, details) => _buildStepperControls(details.currentStep),
      ),
    );
  }

  Widget _buildStepWidget(int index) {
    switch (index) {
      case 0:
        return StockItemFormStepBasicDetails(
          viewModel: _viewModel,
          formKey: _stepFormKeys[0],
        );
      case 1:
        return StockItemFormStepClassification(
          viewModel: _viewModel,
          formKey: _stepFormKeys[1],
        );
      case 2:
        return StockItemFormStepTax(
          viewModel: _viewModel,
          formKey: _stepFormKeys[2],
        );
      case 3:
        return StockItemFormStepPricing(
          viewModel: _viewModel,
          formKey: _stepFormKeys[3],
        );
      case 4:
        return StockItemFormStepStock(
          viewModel: _viewModel,
          formKey: _stepFormKeys[4],
        );
      case 5:
        return StockItemFormStepIdentification(
          viewModel: _viewModel,
          formKey: _stepFormKeys[5],
        );
      case 6:
        return StockItemFormStepReview(
          viewModel: _viewModel,
          formKey: _stepFormKeys[6],
          onEditStep: _goToStep,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepperControls(int currentStep) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          if (currentStep > 0)
            TextButton(
              onPressed: _back,
              child: const Text('Back'),
            ),
          const Spacer(),
          if (currentStep < stepCount - 1)
            FilledButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Next'),
            )
          else
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_isSaving ? 'Saving...' : 'Save'),
            ),
        ],
      ),
    );
  }

  void _goToStep(int index) {
    final lastStep = stepCount - 1;
    final clamped = index < 0 ? 0 : (index > lastStep ? lastStep : index);
    if (clamped != _currentStep) {
      setState(() => _currentStep = clamped);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _next() async {
    if (_currentStep >= stepCount - 1) {
      await _save();
      return;
    }
    if (!_validateCurrentStep()) {
      return;
    }
    setState(() => _currentStep += 1);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final viewModel = context.read<StockItemViewModel>();
    final draft = viewModel.draft;
    final request = CreateStockItemRequest(
      name: draft.name,
      code: draft.code,
      alias: draft.alias,
      description: draft.description,
      stockItemType: draft.stockItemType,
      typeOfSupply: draft.typeOfSupply,
      stockGroupId: draft.stockGroupId,
      stockCategoryId: draft.stockCategoryId,
      unitId: draft.unitId,
      altUnitId: draft.altUnitId,
      gstRate: draft.gstRate,
      purchasePrice: draft.purchasePrice,
      sellingPrice: draft.sellingPrice,
      openingQuantity: draft.openingQuantity,
      openingValue: draft.openingValue,
      // The create DTO does not accept an opening balance; send the opening
      // quantity as the current quantity on create.
      currentQuantity: draft.openingQuantity,
      reorderLevel: draft.reorderLevel,
      minimumStock: draft.minimumStock,
      maximumStock: draft.maximumStock,
      barcode: draft.barcode,
      hsn: draft.hsn,
      sac: draft.sac,
      manufacturePartNo: draft.manufacturePartNo,
      articleNo: draft.articleNo,
      sku: draft.sku,
      brandId: draft.brandId,
      active: draft.active,
    );
    final ok = await viewModel.addStockItem(request);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      viewModel.draft = const CreateStockItemRequest(name: '', unitId: '');
      Navigator.of(context).pop();
    } else {
      ErrorHandler.showError(context, viewModel.error);
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == stepCount - 1) {
      // The review step is read-only and always valid.
      return true;
    }
    final formState = _stepFormKeys[_currentStep].currentState;
    if (formState == null) {
      return false;
    }
    if (!formState.validate()) {
      return false;
    }
    final draft = _viewModel.draft;
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return draft.unitId.isNotEmpty &&
            (draft.altUnitId == null || draft.altUnitId != draft.unitId);
      case 2:
        {
          var valid = true;
          if (draft.typeOfSupply == TypeOfSupply.goods) {
            final hsn = draft.hsn?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
            valid = hsn.isNotEmpty && (hsn.length == 4 || hsn.length == 6 || hsn.length == 8);
          } else if (draft.typeOfSupply == TypeOfSupply.services) {
            final sac = draft.sac?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
            valid = sac.isNotEmpty && sac.length == 6;
          }
          final gstRate = draft.gstRate;
          valid = valid && (gstRate == null || (gstRate >= 0 && gstRate <= 100));
          return valid;
        }
      case 3:
        {
          final purchasePrice = draft.purchasePrice;
          final sellingPrice = draft.sellingPrice;
          return (purchasePrice == null || purchasePrice >= 0) &&
              (sellingPrice == null || sellingPrice >= 0);
        }
      case 4:
        {
          final maximumStock = draft.maximumStock;
          final minimumStock = draft.minimumStock;
          final allNonNegative = [
            draft.openingQuantity,
            draft.openingValue,
            draft.reorderLevel,
            draft.minimumStock,
            draft.maximumStock,
          ].every((value) => value == null || value >= 0);
          return allNonNegative &&
              (maximumStock == null || minimumStock == null || maximumStock >= minimumStock);
        }
      case 5:
        return true;
      default:
        return true;
    }
  }
}
