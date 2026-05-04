import 'package:flutter/material.dart';
import 'package:kiwo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kiwo/features/profile/data/services/profile_service.dart';
import 'package:kiwo/features/profile/domain/repositories/profile_repository.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';

class ChangeEmailScreen extends StatefulWidget {
  final String currentEmail;

  const ChangeEmailScreen({super.key, required this.currentEmail});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  late final ProfileRepository _profileRepository;
  final passwordController = TextEditingController();
  final newEmailController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepositoryImpl(ProfileService());
  }

  @override
  void dispose() {
    passwordController.dispose();
    newEmailController.dispose();
    super.dispose();
  }

  void _clearError() {
    setState(() {
      errorMessage = null;
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _changeEmail() async {
    final password = passwordController.text.trim();
    final newEmail = newEmailController.text.trim();

    // Validation
    if (password.isEmpty) {
      setState(() {
        errorMessage = 'Le mot de passe est requis';
      });
      return;
    }
    if (newEmail.isEmpty) {
      setState(() {
        errorMessage = 'Le nouvel email est requis';
      });
      return;
    }
    if (!_isValidEmail(newEmail)) {
      setState(() {
        errorMessage = 'Veuillez entrer un email valide';
      });
      return;
    }
    if (newEmail == widget.currentEmail) {
      setState(() {
        errorMessage = 'Le nouvel email doit être différent de l\'email actuel';
      });
      return;
    }

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      await _profileRepository.changeEmail(password, newEmail);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vérification envoyée! Veuillez vérifier votre nouvel email pour confirmer le changement',
          ),
          backgroundColor: AppColors.green.withValues(alpha: 0.8),
          duration: const Duration(seconds: 5),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      String displayMessage = 'Erreur: ${e.toString()}';
      if (e.toString().contains('wrong-password') ||
          e.toString().contains('invalid-credential')) {
        displayMessage = 'Le mot de passe ne correspond pas';
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
        title: const Text('Changer l\'email'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current email display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email actuel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.currentEmail,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                controller: passwordController,
                obscureText: true,
                enabled: !isLoading,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  hintText: 'Entrez votre mot de passe pour confirmer',
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
                controller: newEmailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _clearError(),
                decoration: InputDecoration(
                  labelText: 'Nouvel email',
                  hintText: 'Entrez votre nouvel email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
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
                      onPressed: _changeEmail,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.green,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Changer l\'email',
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
