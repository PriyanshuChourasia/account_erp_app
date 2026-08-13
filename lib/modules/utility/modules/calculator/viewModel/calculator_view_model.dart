import 'package:flutter/foundation.dart';

import '../../../utils/expression_evaluator.dart';

/// Holds all calculator UI state.
///
/// Screens only ever interact with this class — never with the evaluator
/// directly. The expression is kept as a display string such as
/// `12 + 3 × 4` and evaluated by [ExpressionEvaluator] on demand.
class CalculatorViewModel extends ChangeNotifier {
  String _expression = '';
  String _result = '';
  String? _error;
  bool _justEvaluated = false;

  String get expression => _expression;
  String get result => _result;
  String? get error => _error;

  bool get hasExpression => _expression.isNotEmpty;

  /// True when the displayed result still matches the last `=` press, so the
  /// next digit starts a fresh expression while the next operator reuses it.
  bool get hasResult => _justEvaluated && _result.isNotEmpty;

  void inputDigit(String digit) {
    _error = null;
    if (_justEvaluated) {
      _expression = digit;
      _result = '';
      _justEvaluated = false;
    } else {
      _expression += digit;
    }
    notifyListeners();
  }

  void inputDecimal() {
    _error = null;
    if (_justEvaluated) {
      _expression = '0.';
      _result = '';
      _justEvaluated = false;
    } else {
      final currentOperand = _currentOperand();
      if (currentOperand.contains('.')) return;
      if (currentOperand.isEmpty) {
        _expression += '0.';
      } else {
        _expression += '.';
      }
    }
    notifyListeners();
  }

  void inputOperator(String operator) {
    _error = null;
    if (_justEvaluated && _result.isNotEmpty) {
      _expression = '$_result $operator';
      _result = '';
      _justEvaluated = false;
      notifyListeners();
      return;
    }
    if (_expression.isEmpty) return;
    final trimmed = _expression.trimRight();
    if (_endsWithOperator(trimmed)) {
      _expression = '${trimmed.substring(0, trimmed.length - 1)} $operator';
    } else {
      _expression = '$trimmed $operator';
    }
    notifyListeners();
  }

  void calculate() {
    _error = null;
    final trimmed = _expression.trimRight();
    if (trimmed.isEmpty || _endsWithOperator(trimmed)) {
      _error = 'Incomplete expression';
      notifyListeners();
      return;
    }
    final value = ExpressionEvaluator.tryEvaluate(trimmed);
    if (value == null) {
      _error = 'Cannot compute that expression';
      notifyListeners();
      return;
    }
    _result = _formatResult(value);
    _justEvaluated = true;
    notifyListeners();
  }

  void deleteLast() {
    _error = null;
    if (_expression.isEmpty) return;
    var trimmed = _expression.trimRight();
    if (_endsWithOperator(trimmed)) {
      // Removes the trailing "op" (and its space) from a "… op" expression.
      trimmed = trimmed.substring(0, trimmed.length - 2).trimRight();
    } else {
      trimmed = trimmed.substring(0, trimmed.length - 1).trimRight();
    }
    _expression = trimmed;
    _justEvaluated = false;
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _result = '';
    _error = null;
    _justEvaluated = false;
    notifyListeners();
  }

  String _currentOperand() {
    final tokens = _expression.trimRight().split(RegExp(r'\s+'));
    final last = tokens.isEmpty ? '' : tokens.last;
    if (_endsWithOperator(last)) return '';
    return last;
  }

  bool _endsWithOperator(String value) =>
      value.endsWith('+') ||
      value.endsWith('-') ||
      value.endsWith('×') ||
      value.endsWith('÷');

  String _formatResult(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    final text = value.toStringAsFixed(10);
    var formatted = text;
    while (formatted.contains('.') &&
        (formatted.endsWith('0') || formatted.endsWith('.'))) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }
}
