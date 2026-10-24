import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../domain/chant_models.dart';

/// The large round counter. A thin arc traces the current round of 108 beads;
/// a soft ring spreads outward when a round completes.
class ChantButton extends StatefulWidget {
  const ChantButton({
    super.key,
    required this.count,
    required this.onTap,
    required this.size,
  });

  final int count;
  final VoidCallback onTap;
  final double size;

  @override
  State<ChantButton> createState() => _ChantButtonState();
}

class _ChantButtonState extends State<ChantButton>
    with TickerProviderStateMixin {
  late final _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
  );

  @override
  void didUpdateWidget(ChantButton old) {
    super.didUpdateWidget(old);
    if (widget.count > old.count &&
        completesRound(widget.count) &&
        !MediaQuery.disableAnimationsOf(context)) {
      _ripple.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ripple.dispose();
    _press.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!MediaQuery.disableAnimationsOf(context)) _press.forward();
  }

  void _handleTapEnd() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bead = beadInRound(widget.count);
    final rounds = completedRounds(widget.count);

    return Semantics(
      button: true,
      label: S.chantButtonHint,
      value: '${widget.count} ${S.unitBien}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: (_) => _handleTapEnd(),
        onTapCancel: _handleTapEnd,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_ripple, _press]),
          builder: (context, _) => Transform.scale(
            scale: 1 - 0.025 * _press.value,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _ChantPainter(
                palette: p,
                progress: bead / beadsPerRound,
                ripple: _ripple.isAnimating ? _ripple.value : null,
              ),
              child: SizedBox.square(
                dimension: widget.size,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        formatCount(widget.count),
                        style: TextStyle(
                          fontFamily: Fonts.serif,
                          fontSize: widget.size * 0.24,
                          fontWeight: FontWeight.w400,
                          color: p.text,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Text(
                      S.unitBien,
                      style: TextStyle(
                        fontSize: 16,
                        color: p.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: Space.s),
                    Text(
                      '$bead / $beadsPerRound${rounds > 0 ? '  ·  ${S.round} ${rounds + 1}' : ''}',
                      style: TextStyle(fontSize: 13, color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChantPainter extends CustomPainter {
  _ChantPainter({required this.palette, required this.progress, this.ripple});

  final Palette palette;
  final double progress;
  final double? ripple;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;

    canvas.drawCircle(center, radius, Paint()..color = palette.surface);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = palette.border,
    );

    if (progress > 0) {
      final sweep = 2 * math.pi * progress;
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = palette.accent,
      );
      final head =
          center +
          Offset(math.cos(sweep - math.pi / 2), math.sin(sweep - math.pi / 2)) *
              radius;
      canvas.drawCircle(head, 4.5, Paint()..color = palette.accent);
    }

    if (ripple != null) {
      final t = Curves.easeOut.transform(ripple!);
      canvas.drawCircle(
        center,
        radius + 4 + 28 * t,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = palette.accent.withValues(alpha: 0.6 * (1 - t)),
      );
    }
  }

  @override
  bool shouldRepaint(_ChantPainter old) =>
      old.progress != progress ||
      old.ripple != ripple ||
      old.palette != palette;
}
