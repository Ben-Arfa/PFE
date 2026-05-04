import 'package:flutter/material.dart';
import '../../../../shared/presentation/theme/app_colors.dart';

class Esp32ConnectionIndicator extends StatelessWidget {
  final bool isConnected;
  final String deviceName;
  final VoidCallback onTap;

  const Esp32ConnectionIndicator({
    super.key,
    required this.isConnected,
    this.deviceName = 'ESP32',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isConnected
              ? AppColors.green.withValues(alpha: 0.2)
              : AppColors.beetRed.withValues(alpha: 0.2),
          border: Border.all(
            color: isConnected ? AppColors.green : AppColors.beetRed,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isConnected ? AppColors.green : AppColors.beetRed,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isConnected ? 'Connecté' : 'Déconnecté',
                  style: TextStyle(
                    fontSize: 10,
                    color: isConnected ? AppColors.green : AppColors.beetRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
