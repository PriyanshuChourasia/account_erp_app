/// Pure, dependency-free arithmetic evaluator shared by the calculator and
/// the terminal's `calc` command.
///
/// Supports `+`, `-`, `*`, `/`, parentheses and unary minus. Returns `null`
/// for malformed input (empty expression, trailing operators, double dots,
/// division by zero, …) instead of throwing.
class ExpressionEvaluator {
  ExpressionEvaluator._();

  /// Normalises display glyphs (`×`, `÷`, `−`) to ASCII operators and
  /// evaluates [input]. Returns `null` when the expression is invalid.
  static double? tryEvaluate(String input) {
    final normalized = input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll(' ', '');
    if (normalized.isEmpty) return null;
    try {
      return _Parser(normalized).parse();
    } on FormatException {
      return null;
    }
  }
}

/// Recursive-descent parser for the grammar:
///
/// ```
/// expr    := term (('+' | '-') term)*
/// term    := factor (('*' | '/') factor)*
/// factor  := number | '-' factor | '(' expr ')'
/// number  := digits ('.' digits)?
/// ```
class _Parser {
  _Parser(this._source);

  final String _source;
  int _index = 0;

  double parse() {
    final value = _parseExpression();
    _expectEnd();
    return value;
  }

  double _parseExpression() {
    var value = _parseTerm();
    while (true) {
      final operator = _peekOperator();
      if (operator == null) break;
      if (operator == '+' || operator == '-') {
        _index++;
        final right = _parseTerm();
        value = operator == '+' ? value + right : value - right;
      } else {
        break;
      }
    }
    return value;
  }

  double _parseTerm() {
    var value = _parseFactor();
    while (true) {
      final operator = _peekOperator();
      if (operator == null) break;
      if (operator == '*' || operator == '/') {
        _index++;
        final right = _parseFactor();
        if (operator == '/' && right == 0) {
          throw const FormatException('Division by zero');
        }
        value = operator == '*' ? value * right : value / right;
      } else {
        break;
      }
    }
    return value;
  }

  double _parseFactor() {
    final char = _peek();
    if (char == null) {
      throw const FormatException('Unexpected end of expression');
    }
    if (char == '-') {
      _index++;
      return -_parseFactor();
    }
    if (char == '(') {
      _index++;
      final value = _parseExpression();
      if (_peek() != ')') {
        throw const FormatException('Missing closing parenthesis');
      }
      _index++;
      return value;
    }
    return _parseNumber();
  }

  double _parseNumber() {
    final start = _index;
    var hasDot = false;
    while (_index < _source.length) {
      final char = _peek()!;
      if (char == '.') {
        if (hasDot) throw const FormatException('Multiple dots');
        hasDot = true;
      } else if (char.codeUnitAt(0) < 48 || char.codeUnitAt(0) > 57) {
        break;
      }
      _index++;
    }
    if (_index == start) {
      throw const FormatException('Expected a number');
    }
    return double.parse(_source.substring(start, _index));
  }

  String? _peekOperator() {
    if (_index >= _source.length) return null;
    final char = _peek();
    return (char == '+' || char == '-' || char == '*' || char == '/')
        ? char
        : null;
  }

  String? _peek() {
    if (_index >= _source.length) return null;
    return _source[_index];
  }

  void _expectEnd() {
    if (_index != _source.length) {
      throw const FormatException('Unexpected character');
    }
  }
}
