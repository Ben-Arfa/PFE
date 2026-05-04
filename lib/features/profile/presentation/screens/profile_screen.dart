import 'package:flutter/material.dart';
import 'package:kiwo/app/di/service_locator.dart';
import 'package:kiwo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kiwo/features/profile/data/services/profile_service.dart';
import 'package:kiwo/features/profile/domain/entities/user_profile.dart';
import 'package:kiwo/features/profile/domain/repositories/profile_repository.dart';

import 'package:kiwo/features/profile/presentation/screens/change_password_screen.dart';
import 'package:kiwo/features/profile/presentation/screens/change_email_screen.dart';
import 'package:kiwo/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:kiwo/features/profile/presentation/widgets/profile_menu_item_widget.dart';
import 'package:kiwo/features/profile/presentation/widgets/profile_section_widget.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';
import 'package:kiwo/shared/presentation/theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileRepository _profileRepository;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepositoryImpl(ProfileService());
  }

  @override
  Widget build(BuildContext context) {
    final authUseCases = ServiceLocator.instance.authUseCases;
    final t = ThemeProvider.instance;

    return StreamBuilder<UserProfile?>(
      stream: _profileRepository.watchCurrentUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Erreur lors du chargement du profil'),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        final profile =
            snapshot.data ??
            UserProfile(
              id: 'unknown',
              firstName: '',
              lastName: '',
              email: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

        return Scaffold(
          backgroundColor: t.bgColor,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 12),
              // Profile Icon Header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 40,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information Section
              ProfileSectionWidget(
                title: 'Informations personnelles',
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nom et Prénom',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.fullName.isEmpty
                              ? 'Non défini'
                              : profile.fullName,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Email Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.email,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Security Section
              ProfileSectionWidget(
                title: 'Sécurité',
                children: [
                  ProfileMenuItemWidget(
                    icon: Icons.lock_outline_rounded,
                    label: 'Changer le mot de passe',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ProfileMenuItemWidget(
                    icon: Icons.email_outlined,
                    label: 'Changer l\'email',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangeEmailScreen(currentEmail: profile.email),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Account Section
              ProfileSectionWidget(
                title: 'Compte',
                children: [
                  ProfileMenuItemWidget(
                    icon: Icons.edit_outlined,
                    label: 'Modifier le profil',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfileScreen(profile: profile),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ProfileMenuItemWidget(
                    icon: Icons.logout_rounded,
                    label: 'Se déconnecter',
                    iconColor: AppColors.beetRed,
                    onTap: () => _showLogoutDialog(context, authUseCases),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, dynamic authUseCases) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              authUseCases.signOut();
              Navigator.pop(context);
            },
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: AppColors.beetRed),
            ),
          ),
        ],
      ),
    );
  }
}
