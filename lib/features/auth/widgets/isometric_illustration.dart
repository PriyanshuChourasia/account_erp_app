import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';

/// A pure-Flutter isometric illustration showing the Account ERP workflow
/// as a 3D tabletop diorama with five object clusters on pedestals,
/// connected by a glowing blue road with arrow chevrons.
///
/// Each pedestal subtly bobs up and down with a staggered phase offset
/// for a living, organic feel.
///
/// To replace with a real image later, swap this widget for an `Image.asset`
/// in [FeaturesPanel].
class IsometricIllustration extends StatefulWidget {
  const IsometricIllustration({super.key});

  @override
  State<IsometricIllustration> createState() => _IsometricIllustrationState();
}

class _IsometricIllustrationState extends State<IsometricIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _DioramaPainter(bobValue: _controller.value),
            );
          },
        );
      },
    );
  }
}

/// Draws the 3D diorama scene with floating pedestals.
class _DioramaPainter extends CustomPainter {
  _DioramaPainter({required this.bobValue});

  /// Current animation value in [0, 1). Multiplied by 2π to get the angle.
  final double bobValue;

  /// Maximum vertical bob offset in logical pixels.
  static const double _maxBob = 6.0;

  /// Per-cluster phase offsets (radians) so clusters bob at different times.
  static const List<double> _phaseOffsets = [0.0, 1.2, 2.5, 3.8, 5.0];

  double _bobOffset(int index) {
    final angle = bobValue * 2 * math.pi + _phaseOffsets[index];
    return math.sin(angle) * _maxBob;
  }

  // Reusable paint objects
  final _shadowPaint = Paint()..style = PaintingStyle.fill;
  final _pedestalPaint = Paint()..style = PaintingStyle.fill;
  final _pedestalSidePaint = Paint()..style = PaintingStyle.fill;
  final _pedestalBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final _objectPaint = Paint()..style = PaintingStyle.fill;
  final _accentPaint = Paint()..style = PaintingStyle.fill;
  final _arrowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base pedestal positions — slight zigzag for depth
    final baseCenters = [
      Offset(w * 0.10, h * 0.52), // 1. Lock + keycard
      Offset(w * 0.30, h * 0.38), // 2. Laptop
      Offset(w * 0.50, h * 0.55), // 3. Boxes + barcode
      Offset(w * 0.70, h * 0.40), // 4. Ledger + coins + scale
      Offset(w * 0.90, h * 0.50), // 5. Calculator + terminal
    ];

    // Apply bob offset to each pedestal (shadow stays fixed)
    final centers = [
      for (var i = 0; i < baseCenters.length; i++)
        Offset(baseCenters[i].dx, baseCenters[i].dy + _bobOffset(i)),
    ];

    // ── Glowing road (ground path, no bob) ──
    _drawRoad(canvas, baseCenters, w, h);

    // ── Draw pedestals + objects (with bob) ──
    for (var i = 0; i < centers.length; i++) {
      _drawCluster(canvas, centers[i], baseCenters[i], w, h, i);
    }

    // ── Arrow chevrons along road ──
    _drawArrows(canvas, baseCenters, w);
  }

  // ─── Road ────────────────────────────────────────────────────────────────

  void _drawRoad(Canvas canvas, List<Offset> centers, double w, double h) {
    final roadPaint = Paint()
      ..shader = LinearGradient(
        colors: AppColors.gradientBlue,
      ).createShader(Rect.fromLTWH(0, 0, w, 0))
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Glow underneath
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.15),
          AppColors.primary.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, 0))
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final yBase = h * 0.70;
    path.moveTo(centers[0].dx, yBase);
    for (var i = 1; i < centers.length; i++) {
      final prev = centers[i - 1];
      final curr = centers[i];
      final cp1x = prev.dx + (curr.dx - prev.dx) * 0.5;
      final cp2x = prev.dx + (curr.dx - prev.dx) * 0.5;
      path.cubicTo(cp1x, yBase - 4, cp2x, yBase + 4, curr.dx, yBase);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, roadPaint);
  }

  // ─── Arrow Chevrons ─────────────────────────────────────────────────────

  void _drawArrows(Canvas canvas, List<Offset> centers, double w) {
    _arrowPaint.color = AppColors.primary.withValues(alpha: 0.5);
    final yBase = centers[0].dy + (w * 0.70 - centers[0].dy);
    final arrowY = yBase;

    for (var i = 0; i < centers.length - 1; i++) {
      final mx = (centers[i].dx + centers[i + 1].dx) / 2;
      final sz = w * 0.014;
      final arrow = Path()
        ..moveTo(mx - sz, arrowY - sz)
        ..lineTo(mx + sz * 0.3, arrowY)
        ..lineTo(mx - sz, arrowY + sz);
      canvas.drawPath(arrow, _arrowPaint);
    }
  }

  // ─── Clusters ────────────────────────────────────────────────────────────

  /// [center] is the bobbed position; [groundCenter] is the fixed shadow pos.
  void _drawCluster(
    Canvas canvas,
    Offset center,
    Offset groundCenter,
    double w,
    double h,
    int idx,
  ) {
    final pw = w * 0.13;
    final ph = pw * 0.35;
    final pr = pw / 2;

    // ── Shadow (fixed on ground, no bob) ──
    _shadowPaint.color = AppColors.primary.withValues(alpha: 0.06);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(groundCenter.dx, groundCenter.dy + ph + 4),
        width: pw * 1.1,
        height: pw * 0.3,
      ),
      _shadowPaint,
    );

    // ── Pedestal top face (bobs) ──
    final topGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, const Color(0xFFEDF1F7)],
    );
    _pedestalPaint.shader = topGrad.createShader(
      Rect.fromCircle(center: center, radius: pr),
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: pw, height: pw * 0.55),
      _pedestalPaint,
    );

    // ── Pedestal side face (bobs) ──
    _pedestalSidePaint.color = const Color(0xFFD8DFEA);
    final sideRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + ph * 0.6),
        width: pw,
        height: ph,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(sideRect, _pedestalSidePaint);

    // ── Pedestal border (bobs) ──
    _pedestalBorderPaint.color = AppColors.border;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: pw, height: pw * 0.55),
      _pedestalBorderPaint,
    );

    // ── Objects on pedestal (bobs with pedestal) ──
    final objCenter = Offset(center.dx, center.dy - ph * 0.2);
    switch (idx) {
      case 0:
        _drawLockAndKeycard(canvas, objCenter, pw);
        break;
      case 1:
        _drawLaptop(canvas, objCenter, pw);
        break;
      case 2:
        _drawBoxesAndBarcode(canvas, objCenter, pw);
        break;
      case 3:
        _drawLedgerAndCoins(canvas, objCenter, pw);
        break;
      case 4:
        _drawCalculatorAndTerminal(canvas, objCenter, pw);
        break;
    }
  }

  // ─── Cluster 0: Padlock + Keycard ────────────────────────────────────────

  void _drawLockAndKeycard(Canvas canvas, Offset c, double pw) {
    final s = pw * 0.18;

    // Padlock body
    _objectPaint.color = const Color(0xFF475569);
    final lockBody = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(c.dx - s * 0.3, c.dy + s * 0.2),
        width: s * 1.6,
        height: s * 1.4,
      ),
      Radius.circular(s * 0.3),
    );
    canvas.drawRRect(lockBody, _objectPaint);

    // Padlock shackle
    final shacklePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.35
      ..strokeCap = StrokeCap.round;
    final shackleRect = Rect.fromCenter(
      center: Offset(c.dx - s * 0.3, c.dy - s * 0.3),
      width: s * 1.0,
      height: s * 0.9,
    );
    canvas.drawArc(shackleRect, math.pi, math.pi, false, shacklePaint);

    // Keyhole
    _accentPaint.color = Colors.white;
    canvas.drawCircle(
      Offset(c.dx - s * 0.3, c.dy + s * 0.15),
      s * 0.18,
      _accentPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(c.dx - s * 0.3, c.dy + s * 0.45),
        width: s * 0.12,
        height: s * 0.3,
      ),
      _accentPaint,
    );

    // Keycard (tilted)
    _objectPaint.color = const Color(0xFF60A5FA);
    canvas.save();
    canvas.translate(c.dx + s * 0.8, c.dy + s * 0.1);
    canvas.rotate(-0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 1.4, height: s * 0.9),
        Radius.circular(s * 0.12),
      ),
      _objectPaint,
    );
    _accentPaint.color = Colors.white.withValues(alpha: 0.6);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, -s * 0.15),
        width: s * 1.0,
        height: s * 0.12,
      ),
      _accentPaint,
    );
    canvas.restore();
  }

  // ─── Cluster 1: Laptop ──────────────────────────────────────────────────

  void _drawLaptop(Canvas canvas, Offset c, double pw) {
    final s = pw * 0.18;

    canvas.save();
    canvas.translate(c.dx, c.dy - s * 0.5);
    canvas.rotate(-0.05);

    // Screen bezel
    _objectPaint.color = const Color(0xFF334155);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 2.4, height: s * 1.6),
        Radius.circular(s * 0.15),
      ),
      _objectPaint,
    );

    // Screen display
    _objectPaint.color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -s * 0.05),
          width: s * 2.1,
          height: s * 1.3,
        ),
        Radius.circular(s * 0.08),
      ),
      _objectPaint,
    );

    // Bar chart
    final barColors = [
      AppColors.primary,
      const Color(0xFF34D399),
      const Color(0xFFFBBF24),
      AppColors.primary,
    ];
    final barHeights = [0.6, 0.9, 0.5, 0.75];
    for (var i = 0; i < 4; i++) {
      _accentPaint.color = barColors[i];
      final bx = -s * 0.7 + i * s * 0.45;
      final bh = s * barHeights[i] * 0.6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(bx, s * 0.3 - bh / 2),
            width: s * 0.28,
            height: bh,
          ),
          Radius.circular(s * 0.05),
        ),
        _accentPaint,
      );
    }
    canvas.restore();

    // Keyboard base
    _objectPaint.color = const Color(0xFF94A3B8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + s * 0.7),
          width: s * 2.6,
          height: s * 0.5,
        ),
        Radius.circular(s * 0.08),
      ),
      _objectPaint,
    );
  }

  // ─── Cluster 2: Boxes + Barcode ─────────────────────────────────────────

  void _drawBoxesAndBarcode(Canvas canvas, Offset c, double pw) {
    final s = pw * 0.16;

    final boxColor = const Color(0xFFD97706);
    final boxDark = const Color(0xFF92400E);

    for (var i = 0; i < 3; i++) {
      final bx = c.dx - s * 0.6 + i * s * 0.15;
      final by = c.dy + s * 0.5 - i * s * 0.9;
      final bw = s * 1.4 - i * s * 0.1;
      final bh = s * 0.85;

      _objectPaint.color = boxColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(bx, by), width: bw, height: bh),
          Radius.circular(s * 0.1),
        ),
        _objectPaint,
      );

      _accentPaint.color = boxDark;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(bx, by - bh * 0.3),
          width: bw * 0.8,
          height: bh * 0.15,
        ),
        _accentPaint,
      );
    }

    // Barcode tag
    canvas.save();
    canvas.translate(c.dx + s * 1.3, c.dy + s * 0.1);
    canvas.rotate(0.12);
    _objectPaint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 0.8, height: s * 1.1),
        Radius.circular(s * 0.08),
      ),
      _objectPaint,
    );
    _accentPaint.color = const Color(0xFF1E293B);
    for (var i = 0; i < 5; i++) {
      final lx = -s * 0.2 + i * s * 0.1;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(lx, -s * 0.05),
          width: s * 0.04,
          height: s * 0.6,
        ),
        _accentPaint,
      );
    }
    canvas.restore();
  }

  // ─── Cluster 3: Ledger + Coins + Scale ──────────────────────────────────

  void _drawLedgerAndCoins(Canvas canvas, Offset c, double pw) {
    final s = pw * 0.16;

    // Ledger book
    _objectPaint.color = const Color(0xFF1D4ED8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx - s * 0.8, c.dy),
          width: s * 1.6,
          height: s * 1.8,
        ),
        Radius.circular(s * 0.12),
      ),
      _objectPaint,
    );
    _accentPaint.color = const Color(0xFF1E3A8A);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(c.dx - s * 1.5, c.dy),
        width: s * 0.15,
        height: s * 1.8,
      ),
      _accentPaint,
    );

    // Pen
    _objectPaint.color = const Color(0xFF475569);
    canvas.save();
    canvas.translate(c.dx - s * 0.8, c.dy - s * 1.1);
    canvas.rotate(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 2.0, height: s * 0.18),
        Radius.circular(s * 0.09),
      ),
      _objectPaint,
    );
    canvas.restore();

    // Gold coins
    for (var i = 0; i < 3; i++) {
      _accentPaint.color = const Color(0xFFFBBF24);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx + s * 0.7, c.dy + s * 0.6 - i * s * 0.25),
          width: s * 0.8,
          height: s * 0.3,
        ),
        _accentPaint,
      );
    }

    // Balance scale
    _objectPaint.color = const Color(0xFF92400E);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(c.dx + s * 1.6, c.dy + s * 0.2),
        width: s * 0.12,
        height: s * 1.0,
      ),
      _objectPaint,
    );
    _objectPaint.color = const Color(0xFFD97706);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx + s * 1.6, c.dy - s * 0.5),
          width: s * 1.6,
          height: s * 0.12,
        ),
        Radius.circular(s * 0.06),
      ),
      _objectPaint,
    );
    _accentPaint.color = const Color(0xFFFBBF24);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx + s * 0.9, c.dy - s * 0.3),
        width: s * 0.6,
        height: s * 0.2,
      ),
      _accentPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx + s * 2.3, c.dy - s * 0.3),
        width: s * 0.6,
        height: s * 0.2,
      ),
      _accentPaint,
    );
  }

  // ─── Cluster 4: Calculator + Terminal ────────────────────────────────────

  void _drawCalculatorAndTerminal(Canvas canvas, Offset c, double pw) {
    final s = pw * 0.16;

    // Calculator body
    _objectPaint.color = const Color(0xFF475569);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx - s * 0.8, c.dy + s * 0.1),
          width: s * 1.2,
          height: s * 1.6,
        ),
        Radius.circular(s * 0.15),
      ),
      _objectPaint,
    );
    // Calculator screen
    _objectPaint.color = const Color(0xFFCBD5E1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx - s * 0.8, c.dy - s * 0.35),
          width: s * 0.9,
          height: s * 0.45,
        ),
        Radius.circular(s * 0.06),
      ),
      _objectPaint,
    );
    // Calculator buttons
    _accentPaint.color = const Color(0xFF94A3B8);
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(
                c.dx - s * 1.1 + col * s * 0.3,
                c.dy + s * 0.1 + row * s * 0.3,
              ),
              width: s * 0.22,
              height: s * 0.22,
            ),
            Radius.circular(s * 0.04),
          ),
          _accentPaint,
        );
      }
    }

    // Terminal / monitor
    _objectPaint.color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx + s * 0.8, c.dy - s * 0.1),
          width: s * 1.4,
          height: s * 1.2,
        ),
        Radius.circular(s * 0.1),
      ),
      _objectPaint,
    );
    _objectPaint.color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx + s * 0.8, c.dy - s * 0.15),
          width: s * 1.15,
          height: s * 0.85,
        ),
        Radius.circular(s * 0.06),
      ),
      _objectPaint,
    );
    // Green cursor
    _accentPaint.color = const Color(0xFF34D399);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(c.dx + s * 0.55, c.dy - s * 0.1),
        width: s * 0.5,
        height: s * 0.06,
      ),
      _accentPaint,
    );
    // Monitor stand
    _objectPaint.color = const Color(0xFF475569);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(c.dx + s * 0.8, c.dy + s * 0.65),
        width: s * 0.15,
        height: s * 0.4,
      ),
      _objectPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx + s * 0.8, c.dy + s * 0.85),
        width: s * 0.7,
        height: s * 0.15,
      ),
      _objectPaint,
    );

    // Rolled report
    canvas.save();
    canvas.translate(c.dx + s * 1.6, c.dy + s * 0.3);
    canvas.rotate(0.2);
    _objectPaint.color = const Color(0xFFF1F5F9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 0.5, height: s * 1.2),
        Radius.circular(s * 0.15),
      ),
      _objectPaint,
    );
    _accentPaint.color = AppColors.border;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 0.5, height: s * 1.2),
        Radius.circular(s * 0.15),
      ),
      _accentPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DioramaPainter old) => old.bobValue != bobValue;
}
