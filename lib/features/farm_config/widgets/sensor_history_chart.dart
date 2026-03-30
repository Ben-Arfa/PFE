// lib/features/farm_config/widgets/sensor_history_chart.dart
//
// Graphique sparkline de l'historique d'un capteur (60 dernières secondes).
// Dessiné avec CustomPainter — aucune dépendance externe requise.

import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/models.dart';

class SensorHistoryChart extends StatelessWidget {
  final SensorState state;
  final double alertMin; // seuil bas (peut être null → pas de seuil)
  final double? alertMax; // seuil haut
  final Color color;
  final double height;

  const SensorHistoryChart({
    required this.state,
    required this.color,
    this.alertMin = double.negativeInfinity,
    this.alertMax,
    this.height = 60,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (state.history.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'En attente de données…',
            style: TextStyle(
              color: AppColors.muted.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          readings: state.history,
          rangeMin: state.min,
          rangeMax: state.max,
          color: color,
          alertMin: alertMin,
          alertMax: alertMax,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  final List<SensorReading> readings;
  final double rangeMin, rangeMax;
  final double alertMin;
  final double? alertMax;
  final Color color;

  _SparklinePainter({
    required this.readings,
    required this.rangeMin,
    required this.rangeMax,
    required this.color,
    required this.alertMin,
    required this.alertMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final range = rangeMax - rangeMin;
    if (range <= 0) return;

    // Calcule les points
    final points = <Offset>[];
    for (int i = 0; i < readings.length; i++) {
      final x =
          (i / (readings.length - 1).clamp(1, double.infinity)) * size.width;
      final y =
          size.height - ((readings[i].value - rangeMin) / range) * size.height;
      points.add(Offset(x, y.clamp(0, size.height)));
    }

    // Zone de remplissage (gradient)
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // Ligne principale
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      // Courbe de Bézier douce
      final prev = points[i - 1];
      final curr = points[i];
      final cpX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Ligne de seuil haut (alertMax)
    if (alertMax != null && alertMax! <= rangeMax) {
      final alertY =
          size.height - ((alertMax! - rangeMin) / range) * size.height;
      canvas.drawLine(
        Offset(0, alertY.clamp(0, size.height)),
        Offset(size.width, alertY.clamp(0, size.height)),
        Paint()
          ..color = AppColors.beetRed.withOpacity(0.5)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..shader = null
          ..isAntiAlias = true,
      );
    }

    // Point courant (dernière valeur)
    if (points.isNotEmpty) {
      final last = points.last;
      canvas.drawCircle(last, 3, Paint()..color = color);
      canvas.drawCircle(last, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.readings != readings || old.color != color;
}
