import 'dart:math' as math;

import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;

  const Sparkline({super.key, required this.values, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cleanedValues = values.where((v) => v.isFinite).toList();

    if (cleanedValues.isEmpty) {
      return SizedBox(
        height: 96,
        child: Center(
          child: Text(
            'Aucune donnee',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor.withValues(alpha: 0.55),
            ),
          ),
        ),
      );
    }

    final minValue = cleanedValues.reduce(math.min);
    final maxValue = cleanedValues.reduce(math.max);
    final lastValue = cleanedValues.last;

    return SizedBox(
      height: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricLabel(label: 'Min', value: minValue, color: textColor),
              _MetricLabel(label: 'Dernier', value: lastValue, color: color),
              _MetricLabel(label: 'Max', value: maxValue, color: textColor),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(
                values: cleanedValues,
                color: color,
                labelColor: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricLabel extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MetricLabel({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label ${_formatValue(value)}',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color.withValues(alpha: 0.76),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color labelColor;

  const _LineChartPainter({
    required this.values,
    required this.color,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = labelColor.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.length == 1) {
      _drawSinglePoint(canvas, size);
      return;
    }

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = maxValue == minValue ? 1.0 : maxValue - minValue;
    final points = <Offset>[];

    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final normalized = (values[i] - minValue) / span;
      final y = size.height - (normalized * size.height);
      points.add(Offset(x, y));
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
      fillPath.lineTo(points[i].dx, points[i].dy);
    }

    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final pointStep = math.max(1, (points.length / 8).ceil());
    for (var i = 0; i < points.length; i++) {
      if (i == 0 || i == points.length - 1 || i % pointStep == 0) {
        canvas.drawCircle(points[i], 4.2, pointBorderPaint);
        canvas.drawCircle(points[i], 2.8, pointPaint);
      }
    }
  }

  void _drawSinglePoint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
    canvas.drawCircle(center, 5, pointBorderPaint);
    canvas.drawCircle(center, 3.2, pointPaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.labelColor != labelColor;
  }
}

String _formatValue(double value) {
  if (value.abs() >= 100 || value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  if (value.abs() >= 10) return value.toStringAsFixed(1);
  return value.toStringAsFixed(2);
}
