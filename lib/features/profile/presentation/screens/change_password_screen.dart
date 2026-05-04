import 'package:flutter/material.dart';
import 'package:kiwo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kiwo/features/profile/data/services/profile_service.dart';
import 'package:kiwo/features/profile/domain/repositories/profile_repository.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final ProfileRepository _profileRepository;
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepositoryImpl(ProfileService());
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearError() {
    setState(() {
      errorMessage = null;
    });
  }

  Future<void> _changePassword() async {
    final oldPw = oldPasswordController.text.trim();
    final newPw = newPasswordController.text.trim();
    final confirmPw = confirmPasswordController.text.trim();

    // Validation
    if (oldPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      setState(() {
        errorMessage = 'Tous les champs sont requis';
      });
      return;
    }
    if (newPw.length < 6) {
      setState(() {
        errorMessage = 'Le mot de passe doit contenir au moins 6 caractères';
      });
      return;
    }
    if (newPw != confirmPw) {
      setState(() {
        errorMessage = 'Les mots de passe ne correspondent pas';
      });
      return;
    }

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      await _profileRepository.changePassword(oldPw, newPw);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mot de passe changé avec succès'),
          backgroundColor: AppColors.green.withValues(alpha: 0.8),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      String displayMessage = 'Erreur: ${e.toString()}';
      if (e.toString().contains('wrong-password') ||
          e.toString().contains('invalid-credential')) {
        displayMessage = 'L\'ancien mot de passe ne correspond pas';
      }
      setState(() {
        isLoading = false;
        errorMessage = displayMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changer le mot de passe'),
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
                controller: oldPasswordController,
                obscureText: true,
                enabled: !isLoading,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: 'Ancien mot de passe',
                  hintText: 'Entrez votre ancien mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                enabled: !isLoading,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  hintText: 'Min 6 caractères',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                enabled: !isLoading,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  hintText: 'Confirmez votre nouveau mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
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
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.green,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Changer le mot de passe',
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
