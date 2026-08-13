import 'package:flutter_test/flutter_test.dart';

import 'package:account_erp_app/modules/utility/modules/calculator/viewModel/calculator_view_model.dart';
import 'package:account_erp_app/modules/utility/modules/terminal/viewModel/terminal_view_model.dart';
import 'package:account_erp_app/modules/utility/utils/expression_evaluator.dart';

void main() {
  group('ExpressionEvaluator', () {
    test('evaluates the four basic operations', () {
      expect(ExpressionEvaluator.tryEvaluate('2+3'), 5);
      expect(ExpressionEvaluator.tryEvaluate('10-4'), 6);
      expect(ExpressionEvaluator.tryEvaluate('3*4'), 12);
      expect(ExpressionEvaluator.tryEvaluate('20/5'), 4);
    });

    test('respects operator precedence', () {
      expect(ExpressionEvaluator.tryEvaluate('1+2*3'), 7);
      expect(ExpressionEvaluator.tryEvaluate('(1+2)*3'), 9);
      expect(ExpressionEvaluator.tryEvaluate('2*3+1'), 7);
    });

    test('handles decimals and unary minus', () {
      expect(ExpressionEvaluator.tryEvaluate('0.5*2'), 1.0);
      expect(ExpressionEvaluator.tryEvaluate('-3+5'), 2);
      expect(ExpressionEvaluator.tryEvaluate('2--3'), 5);
    });

    test('normalises display glyphs', () {
      expect(ExpressionEvaluator.tryEvaluate('2 × 3'), 6);
      expect(ExpressionEvaluator.tryEvaluate('8 ÷ 2'), 4);
      expect(ExpressionEvaluator.tryEvaluate('5 − 2'), 3);
    });

    test('returns null for invalid input', () {
      expect(ExpressionEvaluator.tryEvaluate(''), isNull);
      expect(ExpressionEvaluator.tryEvaluate('2+'), isNull);
      expect(ExpressionEvaluator.tryEvaluate('1..2'), isNull);
      expect(ExpressionEvaluator.tryEvaluate('5/0'), isNull);
      expect(ExpressionEvaluator.tryEvaluate('(2+3'), isNull);
    });
  });

  group('CalculatorViewModel', () {
    test('computes a chained expression with precedence', () {
      final viewModel = CalculatorViewModel();
      viewModel
        ..inputDigit('2')
        ..inputOperator('+')
        ..inputDigit('3')
        ..inputOperator('×')
        ..inputDigit('4')
        ..calculate();
      expect(viewModel.result, '14');
    });

    test('starts a fresh expression after equals', () {
      final viewModel = CalculatorViewModel();
      viewModel
        ..inputDigit('2')
        ..inputOperator('+')
        ..inputDigit('2')
        ..calculate();
      expect(viewModel.result, '4');
      viewModel.inputDigit('5');
      expect(viewModel.expression, '5');
    });

    test('rejects division by zero', () {
      final viewModel = CalculatorViewModel();
      viewModel
        ..inputDigit('5')
        ..inputOperator('÷')
        ..inputDigit('0')
        ..calculate();
      expect(viewModel.error, isNotNull);
      expect(viewModel.result, isEmpty);
    });

    test('clear and backspace behave', () {
      final viewModel = CalculatorViewModel();
      viewModel
        ..inputDigit('1')
        ..inputDigit('2')
        ..inputOperator('+')
        ..inputDigit('3')
        ..deleteLast();
      expect(viewModel.expression, '12 +');
      viewModel.deleteLast();
      expect(viewModel.expression, '12');
      viewModel.clear();
      expect(viewModel.expression, isEmpty);
      expect(viewModel.result, isEmpty);
    });
  });

  group('TerminalViewModel', () {
    test('echo prints its argument', () {
      final viewModel = TerminalViewModel();
      viewModel.submit('echo hello');
      expect(viewModel.lines.last.text, 'hello');
    });

    test('calc evaluates an expression', () {
      final viewModel = TerminalViewModel();
      viewModel.submit('calc (2+3)*4');
      expect(viewModel.lines.last.text, '20');
    });

    test('unknown command reports an error', () {
      final viewModel = TerminalViewModel();
      viewModel.submit('nonsense');
      expect(viewModel.lines.last.text, contains('command not found'));
    });

    test('clear empties the buffer', () {
      final viewModel = TerminalViewModel();
      viewModel.submit('echo x');
      viewModel.submit('clear');
      expect(viewModel.lines, isEmpty);
    });
  });
}
