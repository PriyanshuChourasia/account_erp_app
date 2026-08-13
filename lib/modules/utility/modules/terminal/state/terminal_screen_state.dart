import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../screens/terminal_screen.dart';
import '../viewModel/terminal_view_model.dart';
import '../widgets/terminal_output_view.dart';

/// Terminal palette shared with the output view.
class _TerminalColors {
  _TerminalColors._();

  static const Color surface = Color(0xFF101A2E);
  static const Color text = Color(0xFFE2E8F0);
  static const Color prompt = Color(0xFF34D399);
}

/// State for [TerminalScreen].
class TerminalScreenState extends State<TerminalScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onSubmitted(String value) {
    context.read<TerminalViewModel>().submit(value);
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final terminal = context.watch<TerminalViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Terminal')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (terminal.lines.isEmpty) const _WelcomeBanner(),
              if (terminal.lines.isEmpty) const SizedBox(height: 12),
              Expanded(
                child: TerminalOutputView(
                  lines: terminal.lines,
                  scrollController: _scrollController,
                ),
              ),
              const SizedBox(height: 12),
              _InputBar(
                controller: _textController,
                focusNode: _inputFocus,
                onSubmitted: _onSubmitted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom input row: prompt + monospace text field.
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _TerminalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Text(
            r'guest@account-erp:~$',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: _TerminalColors.prompt,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: _TerminalColors.text,
              ),
              cursorColor: _TerminalColors.prompt,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Type a command, e.g. help',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
                filled: false,
              ),
              textInputAction: TextInputAction.send,
            ),
          ),
        ],
      ),
    );
  }
}

/// Short-lived banner shown while the buffer is empty.
class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _TerminalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: const Text(
        'Welcome to Account ERP terminal. Type `help` to see available commands.',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: _TerminalColors.text,
        ),
      ),
    );
  }
}
