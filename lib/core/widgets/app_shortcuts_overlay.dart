import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_theme.dart';
import '../../routing/app_routes.dart';

/// App-wide chrome: a top-right "S: Support Center" / "H: Help" quick-access
/// bar, plus the matching `S`/`H` keyboard shortcuts. Mounted once around
/// the whole app (see `MaterialApp.builder` in `main.dart`) so it is
/// available on every screen — before and after authentication.
class AppShortcutsOverlay extends StatefulWidget {
  const AppShortcutsOverlay({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<AppShortcutsOverlay> createState() => _AppShortcutsOverlayState();
}

class _AppShortcutsOverlayState extends State<AppShortcutsOverlay> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  /// True while the currently focused widget is a text input — so typing
  /// "h" or "s" into a field doesn't accidentally trigger a shortcut.
  bool _isTextFieldFocused() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;
    var isEditable = false;
    context.visitAncestorElements((element) {
      if (element.widget is EditableText) {
        isEditable = true;
        return false;
      }
      return true;
    });
    return isEditable;
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (_isTextFieldFocused()) return false;

    // LogicalKeyboardKey.keyH covers both 'h' and 'H' —
    // also fall back to the character for platform edge cases.
    final key = event.logicalKey;
    final char = event.character?.toLowerCase();

    final isH = key == LogicalKeyboardKey.keyH || char == 'h';
    final isS = key == LogicalKeyboardKey.keyS || char == 's';

    if (isH) {
      _openHelp();
      return true;
    }
    if (isS) {
      _openSupportCenter();
      return true;
    }
    return false;
  }

  void _openHelp() {
    widget.navigatorKey.currentState?.pushNamed(AppRoutes.help);
  }

  void _openSupportCenter() {
    widget.navigatorKey.currentState?.pushNamed(AppRoutes.support);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          right: 32,
          child: Row(
            children: [
              _QuickAccessChip(
                shortcutLabel: 'S',
                label: 'Support Center',
                onTap: _openSupportCenter,
              ),
              const SizedBox(width: 8),
              _QuickAccessChip(
                shortcutLabel: 'H',
                label: 'Help',
                onTap: _openHelp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAccessChip extends StatelessWidget {
  const _QuickAccessChip({
    required this.shortcutLabel,
    required this.label,
    required this.onTap,
  });

  final String shortcutLabel;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  shortcutLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
