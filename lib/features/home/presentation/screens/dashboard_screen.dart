import 'package:flutter/material.dart';
import 'package:kiwo/core/theme_provider.dart';
import 'package:kiwo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kiwo/features/profile/data/services/profile_service.dart';
import 'package:kiwo/features/profile/domain/entities/user_profile.dart';
import 'package:kiwo/features/home/presentation/screens/notifications_screen.dart';
import 'package:kiwo/features/home/presentation/screens/alerts_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ProfileRepositoryImpl _profileRepository = ProfileRepositoryImpl(
    ProfileService(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeHeader(profileRepository: _profileRepository, theme: theme),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.headerColor,
                      foregroundColor: theme.textColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.notifications_outlined),
                        SizedBox(width: 8),
                        Text('Notifications'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AlertsScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.headerColor,
                      foregroundColor: theme.textColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.warning_amber_outlined),
                        SizedBox(width: 8),
                        Text('Alertes'),
                      ],
                    ),
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

class _WelcomeHeader extends StatelessWidget {
  final ProfileRepositoryImpl profileRepository;
  final ThemeProvider theme;

  const _WelcomeHeader({required this.profileRepository, required this.theme});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: profileRepository.watchCurrentUserProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final firstName = _resolveFirstName(profile);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue${firstName == null ? '' : ', $firstName'} 👋',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tout l\'essentiel en un coup d\'œil.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.textColor.withValues(alpha: 0.78),
                height: 1.25,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  String? _resolveFirstName(UserProfile? profile) {
    final name = profile?.firstName.trim();
    if (name != null && name.isNotEmpty) return name;
    final fullName = profile?.fullName.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return null;
  }
}
