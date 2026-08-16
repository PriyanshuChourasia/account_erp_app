import 'package:flutter/material.dart';

import '../models/terminal_line.dart';

/// Terminal palette — intentionally local to the terminal so it can deviate
/// from the light app theme.
class _TerminalColors {
  _TerminalColors._();

  static const Color background = Color(0xFF0B1220);
  static const Color text = Color(0xFFE2E8F0);
  static const Color prompt = Color(0xFF34D399);
  static const Color command = Color(0xFFE2E8F0);
  static const Color info = Color(0xFF93C5FD);
  static const Color error = Color(0xFFF87171);
}

/// Renders the terminal scrollback buffer with monospace text on a dark
/// background. Exposed for reuse by the terminal screen.
class TerminalOutputView extends StatelessWidget {
  const TerminalOutputView({
    super.key,
    required this.lines,
    this.scrollController,
  });

  final List<TerminalLine> lines;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _TerminalColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: lines.length,
        itemBuilder: (context, index) => _LineView(line: lines[index]),
      ),
    );
  }
}

class _LineView extends StatelessWidget {
  const _LineView({required this.line});

  final TerminalLine line;

  @override
  Widget build(BuildContext context) {
    if (line.text.isEmpty) {
      return const SizedBox(height: 8);
    }

    final Color color;
    switch (line.kind) {
      case TerminalLineKind.command:
        color = _TerminalColors.command;
      case TerminalLineKind.output:
        color = _TerminalColors.text;
      case TerminalLineKind.info:
        color = _TerminalColors.info;
      case TerminalLineKind.error:
        color = _TerminalColors.error;
    }

    final bool isCommand = line.kind == TerminalLineKind.command;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: color,
            height: 1.4,
          ),
          children: isCommand
              ? [
                  const TextSpan(
                    text: 'guest@account-erp',
                    style: TextStyle(color: _TerminalColors.prompt),
                  ),
                  const TextSpan(text: ':'),
                  const TextSpan(
                    text: '~',
                    style: TextStyle(color: _TerminalColors.info),
                  ),
                  const TextSpan(text: '\$ '),
                  TextSpan(
                    text: line.text.substring(line.text.indexOf('\$ ') + 2),
                  ),
                ]
              : [TextSpan(text: line.text)],
        ),
      ),
    );
  }
}
