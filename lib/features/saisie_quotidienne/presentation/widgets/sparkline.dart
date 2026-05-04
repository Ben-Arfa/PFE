import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;

  const Sparkline({super.key, required this.values, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox(height: 40);
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final span = (max - min) == 0 ? 1.0 : (max - min);

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          final normalized = (v - min) / span;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                height: 8 + (normalized * 40),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
