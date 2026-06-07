import 'dart:math' as math;

import 'package:flutter/material.dart';

class CatchLingoBackground extends StatelessWidget {
  const CatchLingoBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _GradientBase()),

        const Positioned.fill(child: _GlowLayer()),

        const Positioned.fill(
          child: IgnorePointer(child: _LassoCharacterLayer()),
        ),

        const Positioned(
          top: 54,
          right: 22,
          child: _FloatingWord(
            text: 'makan',
            emoji: '🍜',
            angle: -0.16,
            scale: 1.02,
          ),
        ),

        const Positioned(
          top: 126,
          left: 18,
          child: _FloatingWord(
            text: 'rumah',
            emoji: '🏠',
            angle: 0.14,
            scale: 0.96,
          ),
        ),

        const Positioned(
          top: 180,
          left: 120,
          child: _FloatingWord(
            text: 'belajar',
            emoji: '📘',
            angle: -0.06,
            scale: 1.0,
            highlighted: true,
          ),
        ),

        const Positioned(
          top: 254,
          right: 34,
          child: _FloatingWord(
            text: 'minum',
            emoji: '🥤',
            angle: 0.20,
            scale: 0.92,
          ),
        ),

        const Positioned(
          bottom: 268,
          left: 24,
          child: _FloatingWord(
            text: 'jalan',
            emoji: '🛵',
            angle: -0.15,
            scale: 1.0,
          ),
        ),

        const Positioned(
          bottom: 206,
          right: 20,
          child: _FloatingWord(
            text: 'terima kasih',
            emoji: '✨',
            angle: 0.10,
            scale: 0.92,
          ),
        ),

        const Positioned(
          bottom: 118,
          left: 42,
          child: _FloatingWord(
            text: 'tidur',
            emoji: '🌙',
            angle: 0.10,
            scale: 0.88,
          ),
        ),

        const Positioned.fill(child: IgnorePointer(child: _SparkleLayer())),

        child,
      ],
    );
  }
}

class _GradientBase extends StatelessWidget {
  const _GradientBase();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.35, -0.72),
          radius: 1.3,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF3F5FF),
            Color(0xFFEAEFFF),
            Color(0xFFE5F8FF),
          ],
        ),
      ),
    );
  }
}

class _GlowLayer extends StatelessWidget {
  const _GlowLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(
          top: -70,
          right: -80,
          child: _GlowCircle(size: 260, color: Color(0x335B5FEF)),
        ),
        Positioned(
          top: 160,
          left: -90,
          child: _GlowCircle(size: 220, color: Color(0x2242C2FF)),
        ),
        Positioned(
          bottom: 20,
          right: -70,
          child: _GlowCircle(size: 240, color: Color(0x2237D39B)),
        ),
        Positioned(
          bottom: -70,
          left: -30,
          child: _GlowCircle(size: 190, color: Color(0x22FFB84D)),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 56, spreadRadius: 18)],
      ),
    );
  }
}

class _FloatingWord extends StatelessWidget {
  const _FloatingWord({
    required this.text,
    required this.emoji,
    required this.angle,
    required this.scale,
    this.highlighted = false,
  });

  final String text;
  final String emoji;
  final double angle;
  final double scale;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final borderColor = highlighted
        ? const Color(0x885B5FEF)
        : const Color(0x335B5FEF);

    final backgroundColor = highlighted
        ? Colors.white.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.78);

    return Transform.rotate(
      angle: angle,
      child: Transform.scale(
        scale: scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: borderColor,
              width: highlighted ? 1.6 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: highlighted
                    ? const Color(0x235B5FEF)
                    : const Color(0x16000000),
                blurRadius: highlighted ? 22 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xDD25283A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LassoCharacterLayer extends StatelessWidget {
  const _LassoCharacterLayer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LassoCharacterPainter());
  }
}

class _LassoCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = const Color(0x12000000)
      ..style = PaintingStyle.fill;

    final bodyPaint = Paint()
      ..color = const Color(0xFF5B5FEF)
      ..style = PaintingStyle.fill;

    final bodySoftPaint = Paint()
      ..color = const Color(0xFF7E82FF)
      ..style = PaintingStyle.fill;

    final limbPaint = Paint()
      ..color = const Color(0xFF3E4480)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final handPaint = Paint()
      ..color = const Color(0xFFFFD6A5)
      ..style = PaintingStyle.fill;

    final ropePaint = Paint()
      ..color = const Color(0xAA5B5FEF)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final ropeSoftPaint = Paint()
      ..color = const Color(0x335B5FEF)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = const Color(0x2237D39B)
      ..style = PaintingStyle.fill;

    final baseX = size.width * 0.76;
    final baseY = size.height * 0.80;

    // shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(baseX - 6, baseY + 52),
        width: 132,
        height: 28,
      ),
      shadowPaint,
    );

    // little accent splash behind body
    canvas.drawCircle(Offset(baseX - 50, baseY - 52), 42, accentPaint);

    // body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(baseX - 8, baseY - 18),
        width: 54,
        height: 86,
      ),
      const Radius.circular(26),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // shoulder / body highlight
    final bodyHighlight = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(baseX - 16, baseY - 34),
        width: 28,
        height: 34,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(bodyHighlight, bodySoftPaint);

    // head
    canvas.drawCircle(Offset(baseX - 10, baseY - 88), 24, handPaint);

    // hair cap
    final hairPath = Path()
      ..moveTo(baseX - 33, baseY - 90)
      ..quadraticBezierTo(baseX - 8, baseY - 117, baseX + 10, baseY - 94)
      ..quadraticBezierTo(baseX - 2, baseY - 68, baseX - 30, baseY - 76)
      ..close();
    canvas.drawPath(hairPath, bodySoftPaint);

    // left arm down
    canvas.drawLine(
      Offset(baseX - 30, baseY - 34),
      Offset(baseX - 56, baseY + 10),
      limbPaint,
    );

    // right arm up / throwing lasso
    canvas.drawLine(
      Offset(baseX + 10, baseY - 40),
      Offset(baseX + 46, baseY - 94),
      limbPaint,
    );

    // hands
    canvas.drawCircle(Offset(baseX - 56, baseY + 10), 6.5, handPaint);
    canvas.drawCircle(Offset(baseX + 46, baseY - 94), 6.5, handPaint);

    // legs
    canvas.drawLine(
      Offset(baseX - 20, baseY + 20),
      Offset(baseX - 38, baseY + 74),
      limbPaint,
    );
    canvas.drawLine(
      Offset(baseX + 6, baseY + 20),
      Offset(baseX + 26, baseY + 74),
      limbPaint,
    );

    // feet
    canvas.drawLine(
      Offset(baseX - 42, baseY + 76),
      Offset(baseX - 18, baseY + 76),
      Paint()
        ..color = const Color(0xFF3E4480)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(baseX + 18, baseY + 76),
      Offset(baseX + 40, baseY + 76),
      Paint()
        ..color = const Color(0xFF3E4480)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    // lasso rope curve
    final ropePath = Path()
      ..moveTo(baseX + 46, baseY - 94)
      ..cubicTo(
        size.width * 0.67,
        size.height * 0.30,
        size.width * 0.42,
        size.height * 0.17,
        size.width * 0.31,
        size.height * 0.24,
      );

    canvas.drawPath(ropePath, ropeSoftPaint);
    canvas.drawPath(ropePath, ropePaint);

    // lasso loop
    final loopRect = Rect.fromCenter(
      center: Offset(size.width * 0.31, size.height * 0.24),
      width: 138,
      height: 88,
    );
    canvas.drawOval(loopRect.inflate(4), ropeSoftPaint);
    canvas.drawOval(loopRect, ropePaint);

    // extra rope tail
    final tailPath = Path()
      ..moveTo(size.width * 0.365, size.height * 0.275)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.29,
        size.width * 0.47,
        size.height * 0.26,
      );
    canvas.drawPath(tailPath, ropePaint);

    // tiny motion lines near loop
    final motionPaint = Paint()
      ..color = const Color(0x335B5FEF)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.23, size.height * 0.23),
        width: 32,
        height: 32,
      ),
      math.pi * 1.25,
      math.pi * 0.35,
      false,
      motionPaint,
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.39, size.height * 0.24),
        width: 28,
        height: 28,
      ),
      math.pi * 1.75,
      math.pi * 0.35,
      false,
      motionPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparkleLayer extends StatelessWidget {
  const _SparkleLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(top: 94, left: 88, child: _Sparkle(size: 10)),
        Positioned(top: 188, right: 94, child: _Sparkle(size: 7)),
        Positioned(top: 340, left: 62, child: _Sparkle(size: 8)),
        Positioned(bottom: 306, right: 120, child: _Sparkle(size: 9)),
        Positioned(bottom: 144, right: 84, child: _Sparkle(size: 7)),
        Positioned(bottom: 86, left: 118, child: _Sparkle(size: 8)),
      ],
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0x665B5FEF),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
