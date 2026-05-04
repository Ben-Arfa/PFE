import 'package:flutter/material.dart';
import 'package:kiwo/features/profile/domain/entities/user_profile.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';
import 'package:kiwo/shared/presentation/theme/theme_provider.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfile profile;

  const ProfileHeaderWidget({required this.profile, super.key});

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.green.withValues(alpha: 0.16),
            backgroundImage: profile.profileImageUrl != null
                ? NetworkImage(profile.profileImageUrl!)
                : null,
            child: profile.profileImageUrl == null
                ? Text(
                    profile.fullName.isNotEmpty
                        ? profile.fullName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName.isEmpty ? 'Utilisateur' : profile.fullName,
                  style: TextStyle(
                    color: t.textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: TextStyle(color: t.mutedColor, fontSize: 13),
                ),
                if (profile.phoneNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.phoneNumber!,
                    style: TextStyle(color: t.mutedColor, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
