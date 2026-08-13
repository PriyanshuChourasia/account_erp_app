import 'package:flutter/foundation.dart';

import '../../../../../config/app_version.dart';
import '../../../utils/expression_evaluator.dart';
import '../models/terminal_line.dart';

/// Holds all terminal UI state: the scrollback buffer and command execution.
/// Screens only ever interact with this class.
class TerminalViewModel extends ChangeNotifier {
  static const String _prompt = r'guest@account-erp:~$';

  final List<TerminalLine> _lines = [];

  String get prompt => _prompt;
  List<TerminalLine> get lines => List.unmodifiable(_lines);

  /// Clears the scrollback buffer.
  void clearScreen() {
    _lines.clear();
    notifyListeners();
  }

  /// Appends the typed command to the buffer and runs it.
  void submit(String rawCommand) {
    final command = rawCommand.trim();

    _lines.add(
      TerminalLine(
        text: '$_prompt $command',
        kind: TerminalLineKind.command,
      ),
    );
    if (command.isEmpty) {
      notifyListeners();
      return;
    }
    _runCommand(command);
    notifyListeners();
  }

  void _runCommand(String command) {
    final parts = command.split(RegExp(r'\s+'));
    final name = parts.first.toLowerCase();
    final args = parts.skip(1).join(' ');

    switch (name) {
      case 'help':
        _lines.addAll(_helpLines);
      case 'clear':
        clearScreen();
      case 'echo':
        _lines.add(TerminalLine(text: args.isEmpty ? '' : args));
      case 'date':
        _lines.add(TerminalLine(text: DateTime.now().toString()));
      case 'whoami':
        _lines.add(const TerminalLine(text: 'guest'));
      case 'pwd':
        _lines.add(const TerminalLine(text: '/home/guest'));
      case 'ls':
        _lines.add(const TerminalLine(text: 'documents/  downloads/  projects/'));
      case 'version':
        _lines.add(
          TerminalLine(text: 'Account ERP terminal v${AppVersion.current}'),
        );
      case 'calc':
        if (args.isEmpty) {
          _lines.add(
            const TerminalLine(
              text: 'Usage: calc <expression>  e.g. calc (2+3)*4',
              kind: TerminalLineKind.error,
            ),
          );
        } else {
          final value = ExpressionEvaluator.tryEvaluate(args);
          if (value == null) {
            _lines.add(
              const TerminalLine(
                text: 'Invalid expression.',
                kind: TerminalLineKind.error,
              ),
            );
          } else {
            _lines.add(TerminalLine(text: _formatNumber(value)));
          }
        }
      default:
        _lines.add(
          TerminalLine(
            text: '$name: command not found. Type `help` for available commands.',
            kind: TerminalLineKind.error,
          ),
        );
    }
  }

  String _formatNumber(double value) {
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

  static const List<TerminalLine> _helpLines = [
    TerminalLine(text: 'Available commands:', kind: TerminalLineKind.info),
    TerminalLine(
      text: '  help        Show this help',
      kind: TerminalLineKind.output,
    ),
    TerminalLine(
      text: '  clear       Clear the screen',
      kind: TerminalLineKind.output,
    ),
    TerminalLine(
      text: '  echo <text> Print text',
      kind: TerminalLineKind.output,
    ),
    TerminalLine(
      text: '  date        Show the current date and time',
      kind: TerminalLineKind.output,
    ),
    TerminalLine(
      text: '  whoami      Show the current user',
      kind: TerminalLineKind.output,
    ),
    TerminalLine(
      text: '  pwd         Print the working directory',
      kind: TerminalLineKind.output,
    ),
    TerminalLine(
      text: '  ls          List directory contents',
      kind: TerminalLineKind.output,
    ),
    TerminalLine(
      text: '  calc <expr> Evaluate an arithmetic expression',
      kind: TerminalLineKind.output,
    ),
    TerminalLine(
      text: '  version     Show the app version',
      kind: TerminalLineKind.output,
    ),
  ];
}
