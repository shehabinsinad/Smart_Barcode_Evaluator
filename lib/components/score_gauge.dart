import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Animated circular score gauge with color-coded ranges
class ScoreGauge extends StatefulWidget {
  final int score;
  final double size;
  final bool animate;

  const ScoreGauge({
    super.key,
    required this.score,
    this.size = 200,
    this.animate = true,
  });

  @override
  State<ScoreGauge> createState() => _ScoreGaugeState();
}

class _ScoreGaugeState extends State<ScoreGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.score / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 71) return AppColors.scoreExcellent;
    if (score >= 61) return AppColors.scoreGood;
    if (score >= 41) return AppColors.scoreFair;
    if (score >= 31) return AppColors.scorePoor;
    return AppColors.scoreBad;
  }

  Gradient _getScoreGradient(int score) {
    if (score >= 71) return AppColors.excellentGradient;
    if (score >= 41) return AppColors.fairGradient;
    return AppColors.badGradient;
  }

  String _getScoreLabel(int score) {
    if (score >= 71) return 'Excellent';
    if (score >= 61) return 'Good';
    if (score >= 41) return 'Fair';
    if (score >= 31) return 'Poor';
    return 'Bad';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getScoreColor(widget.score);
    final gradient = _getScoreGradient(widget.score);
    final label = _getScoreLabel(widget.score);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugeBackgroundPainter(
                  color: color.withValues(alpha: 0.2),
                ),
              ),
              
              // Animated progress arc
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugeProgressPainter(
                  progress: _animation.value,
                  gradient: gradient,
                  strokeWidth: 12,
                ),
              ),
              
              // Score text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(widget.score * _animation.value).toInt()}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: widget.size * 0.25,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class _GaugeBackgroundPainter extends CustomPainter {
  final Color color;

  _GaugeBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GaugeProgressPainter extends CustomPainter {
  final double progress;
  final Gradient gradient;
  final double strokeWidth;

  _GaugeProgressPainter({
    required this.progress,
    required this.gradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
