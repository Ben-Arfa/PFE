import 'package:flutter/material.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';
import 'package:kiwo/shared/presentation/theme/theme_provider.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  final Color iconColor;

  const ProfileMenuItemWidget({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor = AppColors.green,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: t.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: t.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: TextStyle(color: t.mutedColor, fontSize: 12),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right_rounded, color: t.mutedColor, size: 20),
          ],
        ),
      ),
    );
  }
}
