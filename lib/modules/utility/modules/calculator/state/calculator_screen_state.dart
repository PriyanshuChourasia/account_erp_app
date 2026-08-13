import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../screens/calculator_screen.dart';
import '../viewModel/calculator_view_model.dart';
import '../widgets/calculator_button.dart';

/// State for [CalculatorScreen].
class CalculatorScreenState extends State<CalculatorScreen> {
  void _onClear() => context.read<CalculatorViewModel>().clear();

  void _onBackspace() => context.read<CalculatorViewModel>().deleteLast();

  void _onDigit(String digit) =>
      context.read<CalculatorViewModel>().inputDigit(digit);

  void _onOperator(String operator) =>
      context.read<CalculatorViewModel>().inputOperator(operator);

  void _onEquals() => context.read<CalculatorViewModel>().calculate();

  void _onDecimal() => context.read<CalculatorViewModel>().inputDecimal();

  @override
  Widget build(BuildContext context) {
    final calculator = context.watch<CalculatorViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: _Display(calculator: calculator)),
              _Keypad(
                onClear: _onClear,
                onBackspace: _onBackspace,
                onDigit: _onDigit,
                onOperator: _onOperator,
                onEquals: _onEquals,
                onDecimal: _onDecimal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expression + result readout shown above the keypad.
class _Display extends StatelessWidget {
  const _Display({required this.calculator});

  final CalculatorViewModel calculator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (calculator.error != null) ...[
            Text(
              calculator.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (calculator.expression.isNotEmpty)
            Text(
              calculator.expression,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Text(
              calculator.result.isEmpty ? '0' : calculator.result,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.displaySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The keypad grid. Keeps a flat, data-driven layout so rows stay aligned.
class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onClear,
    required this.onBackspace,
    required this.onDigit,
    required this.onOperator,
    required this.onEquals,
    required this.onDecimal,
  });

  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final ValueChanged<String> onDigit;
  final ValueChanged<String> onOperator;
  final VoidCallback onEquals;
  final VoidCallback onDecimal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _KeypadRow([
          CalculatorButton(
            label: 'AC',
            onTap: onClear,
            variant: CalculatorButtonVariant.function,
          ),
          CalculatorButton(
            label: '',
            icon: Icons.backspace_outlined,
            onTap: onBackspace,
            variant: CalculatorButtonVariant.function,
          ),
          CalculatorButton(
            label: '×',
            onTap: () => onOperator('×'),
            variant: CalculatorButtonVariant.operator,
          ),
          CalculatorButton(
            label: '÷',
            onTap: () => onOperator('÷'),
            variant: CalculatorButtonVariant.operator,
          ),
        ]),
        _KeypadRow([
          for (final d in ['7', '8', '9'])
            CalculatorButton(label: d, onTap: () => onDigit(d)),
          CalculatorButton(
            label: '−',
            onTap: () => onOperator('−'),
            variant: CalculatorButtonVariant.operator,
          ),
        ]),
        _KeypadRow([
          for (final d in ['4', '5', '6'])
            CalculatorButton(label: d, onTap: () => onDigit(d)),
          CalculatorButton(
            label: '+',
            onTap: () => onOperator('+'),
            variant: CalculatorButtonVariant.operator,
          ),
        ]),
        _KeypadRow([
          for (final d in ['1', '2', '3'])
            CalculatorButton(label: d, onTap: () => onDigit(d)),
          CalculatorButton(
            label: '=',
            onTap: onEquals,
            variant: CalculatorButtonVariant.operator,
          ),
        ]),
        _KeypadRow([
          CalculatorButton(
            label: '0',
            expanded: true,
            onTap: () => onDigit('0'),
          ),
          CalculatorButton(label: '.', onTap: onDecimal),
        ]),
      ],
    );
  }
}

/// Wraps a list of keys in a full-width row.
class _KeypadRow extends StatelessWidget {
  const _KeypadRow(this.children);

  final List<CalculatorButton> children;

  @override
  Widget build(BuildContext context) => Row(children: children);
}
