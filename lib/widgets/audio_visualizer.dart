import 'dart:math';
import 'package:flutter/material.dart';

/// Animated audio visualizer with multiple styles:
/// 0 = Bars, 1 = Waves, 2 = Spectrogram, 3 = Circular
class AudioVisualizerWidget extends StatefulWidget {
  final int type;
  final bool isPlaying;
  final Color color;
  final double height;
  final int barCount;

  const AudioVisualizerWidget({
    super.key,
    this.type = 0,
    this.isPlaying = false,
    this.color = Colors.white,
    this.height = 80,
    this.barCount = 32,
  });

  @override
  State<AudioVisualizerWidget> createState() => _AudioVisualizerWidgetState();
}

class _AudioVisualizerWidgetState extends State<AudioVisualizerWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<double> _barHeights;
  late List<double> _targetHeights;

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(widget.barCount, (_) => 0.1);
    _targetHeights = List.generate(widget.barCount, (_) => 0.1);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(_updateBars);
    if (widget.isPlaying) _controller.repeat();
  }

  void _updateBars() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < widget.barCount; i++) {
        // Smooth interpolation towards target
        _barHeights[i] += (_targetHeights[i] - _barHeights[i]) * 0.3;
      }
      // Generate new targets periodically
      if (_controller.value > 0.9 || _controller.value < 0.1) {
        _generateTargets();
      }
    });
  }

  void _generateTargets() {
    for (int i = 0; i < widget.barCount; i++) {
      if (widget.isPlaying) {
        // Create a more musical-looking pattern
        final center = widget.barCount / 2;
        final distFromCenter = (i - center).abs() / center;
        final baseLine = 0.3 + (1 - distFromCenter) * 0.4;
        _targetHeights[i] = (baseLine + _random.nextDouble() * 0.5).clamp(0.05, 1.0);
      } else {
        _targetHeights[i] = 0.05 + _random.nextDouble() * 0.05;
      }
    }
  }

  @override
  void didUpdateWidget(AudioVisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _generateTargets(); // Set low targets
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: switch (widget.type) {
        0 => _buildBars(),
        1 => _buildWaves(),
        2 => _buildSpectrogram(),
        3 => _buildCircular(),
        _ => _buildBars(),
      },
    );
  }

  /// Bar visualizer (vertical bars)
  Widget _buildBars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(widget.barCount, (i) {
        final height = _barHeights[i] * widget.height;
        final hue = (i / widget.barCount * 60) + HSLColor.fromColor(widget.color).hue;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: (MediaQuery.of(context).size.width - 64) / widget.barCount - 2,
          height: height.clamp(2.0, widget.height),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                widget.color.withValues(alpha: 0.6),
                HSLColor.fromAHSL(1, hue % 360, 0.8, 0.6).toColor(),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Wave visualizer (smooth sine wave)
  Widget _buildWaves() {
    return CustomPaint(
      painter: _WavePainter(
        heights: _barHeights,
        color: widget.color,
        isPlaying: widget.isPlaying,
      ),
      size: Size.infinite,
    );
  }

  /// Spectrogram visualizer (mirrored bars)
  Widget _buildSpectrogram() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top half (mirrored)
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.barCount, (i) {
              final height = _barHeights[i] * widget.height / 2;
              return Container(
                width: (MediaQuery.of(context).size.width - 64) / widget.barCount - 2,
                height: height.clamp(1.0, widget.height / 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: widget.color.withValues(alpha: _barHeights[i]),
                ),
              );
            }),
          ),
        ),
        // Bottom half (mirrored)
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.barCount, (i) {
              final height = _barHeights[i] * widget.height / 2;
              return Container(
                width: (MediaQuery.of(context).size.width - 64) / widget.barCount - 2,
                height: height.clamp(1.0, widget.height / 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: widget.color.withValues(alpha: _barHeights[i] * 0.6),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  /// Circular visualizer
  Widget _buildCircular() {
    return Center(
      child: CustomPaint(
        painter: _CircularPainter(
          heights: _barHeights,
          color: widget.color,
        ),
        size: Size.square(widget.height),
      ),
    );
  }
}

/// Custom painter for wave visualization
class _WavePainter extends CustomPainter {
  final List<double> heights;
  final Color color;
  final bool isPlaying;

  _WavePainter({required this.heights, required this.color, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.3), color, color.withValues(alpha: 0.3)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final mid = size.height / 2;

    path.moveTo(0, mid);
    fillPath.moveTo(0, mid);

    for (int i = 0; i < heights.length; i++) {
      final x = i * size.width / (heights.length - 1);
      final y = mid - (heights[i] - 0.5) * size.height * 0.8;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        final prevX = (i - 1) * size.width / (heights.length - 1);
        final ctrlX = (prevX + x) / 2;
        path.quadraticBezierTo(ctrlX, mid - (heights[i - 1] - 0.5) * size.height * 0.8, x, y);
        fillPath.quadraticBezierTo(ctrlX, mid - (heights[i - 1] - 0.5) * size.height * 0.8, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}

/// Custom painter for circular visualization
class _CircularPainter extends CustomPainter {
  final List<double> heights;
  final Color color;

  _CircularPainter({required this.heights, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.25;

    for (int i = 0; i < heights.length; i++) {
      final angle = (i / heights.length) * 2 * pi;
      final barLength = heights[i] * baseRadius * 0.8;
      final startRadius = baseRadius;
      final endRadius = baseRadius + barLength;

      final start = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );
      final end = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      final hue = (i / heights.length * 360 + HSLColor.fromColor(color).hue) % 360;

      final paint = Paint()
        ..color = HSLColor.fromAHSL(heights[i], hue, 0.8, 0.6).toColor()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(start, end, paint);
    }

    // Center circle
    canvas.drawCircle(
      center,
      baseRadius - 2,
      Paint()..color = color.withValues(alpha: 0.1),
    );
  }

  @override
  bool shouldRepaint(covariant _CircularPainter oldDelegate) => true;
}
