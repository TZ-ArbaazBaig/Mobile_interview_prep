import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ScoreRing extends StatelessWidget {
  final double score; // 1.0 to 10.0
  final double size;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 160.0,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = score / 10.0;
    
    Color baseColor;
    if (score >= 8.0) {
      baseColor = const Color(0xFF34D399); // emerald
    } else if (score >= 5.0) {
      baseColor = const Color(0xFFA855F7); // violet
    } else {
      baseColor = const Color(0xFFFB7185); // rose
    }
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: percentage),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: 0.15 * value),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _ScoreRingPainter(progress: value, color: baseColor),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    score.toStringAsFixed(1),
                    style: AppTextStyles.h1().copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'out of 10',
                    style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScoreRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    const strokeWidth = 12.0;

    // Track Paint (gray background circle)
    final trackPaint = Paint()
      ..color = AppColors.charcoalCard
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Active Paint (gradient arc using dynamic base color)
    final activePaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.6),
          color,
          color.withValues(alpha: 0.9),
          color.withValues(alpha: 0.6),
        ],
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);
    
    // Draw the arc starting from the top (-pi/2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
