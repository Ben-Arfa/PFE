import 'package:flutter/material.dart';
import 'package:kiwo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kiwo/features/profile/data/services/profile_service.dart';
import 'package:kiwo/features/profile/domain/entities/user_profile.dart';
import 'package:kiwo/features/profile/domain/repositories/profile_repository.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileRepository _profileRepository;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepositoryImpl(ProfileService());
    firstNameController = TextEditingController(text: widget.profile.firstName);
    lastNameController = TextEditingController(text: widget.profile.lastName);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void _clearError() {
    setState(() {
      errorMessage = null;
    });
  }

  Future<void> _updateProfile() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    // Validation
    if (firstName.isEmpty && lastName.isEmpty) {
      setState(() {
        errorMessage = 'Au moins l\'un des champs est requis';
      });
      return;
    }

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      // Préparer les données mises à jour
      final updatedData = <String, String>{};
      if (firstName.isNotEmpty) {
        updatedData['firstName'] = firstName;
      }
      if (lastName.isNotEmpty) {
        updatedData['lastName'] = lastName;
      }

      // Mettre à jour chaque champ
      for (final entry in updatedData.entries) {
        await _profileRepository.updateProfileField(entry.key, entry.value);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil mis à jour avec succès'),
          backgroundColor: AppColors.green.withValues(alpha: 0.8),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.beetRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.beetRed),
                  ),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: AppColors.beetRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              TextField(
                controller: firstNameController,
                enabled: !isLoading,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  hintText: 'Entrez votre prénom',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: lastNameController,
                enabled: !isLoading,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Entrez votre nom',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.green,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
