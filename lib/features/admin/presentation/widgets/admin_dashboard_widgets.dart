import 'package:flutter/material.dart';
import 'package:kiwo/app/di/service_locator.dart';
import 'package:kiwo/features/admin/domain/entities/admin_user.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';
import 'package:kiwo/shared/presentation/theme/theme_provider.dart';

class AdminDashboardIntroCard extends StatelessWidget {
  const AdminDashboardIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue, Admin',
                  style: TextStyle(
                    color: t.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Gerrez les comptes utilisateurs simplement et rapidement.',
                  style: TextStyle(
                    color: t.mutedColor,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminShortcutCard extends StatelessWidget {
  final Color borderColor;
  final Color backgroundColor;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color iconColor;
  final double iconSize;
  final double verticalPadding;

  const AdminShortcutCard({
    super.key,
    required this.borderColor,
    required this.backgroundColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.iconColor,
    this.iconSize = 32,
    this.verticalPadding = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(verticalPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminUserListHeader extends StatelessWidget {
  const AdminUserListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.borderColor),
      ),
      child: const ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: Icon(Icons.manage_accounts_rounded, color: AppColors.green),
        title: Text(
          'Comptes utilisateurs',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'Chaque utilisateur apparaît dans sa propre carte avec son nom, son prenom et son email.',
        ),
      ),
    );
  }
}

class AdminUserInfoCard extends StatelessWidget {
  final AdminUser user;
  final bool deleteMode;
  final VoidCallback onDelete;

  const AdminUserInfoCard({
    super.key,
    required this.user,
    required this.deleteMode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    final fullName = user.fullName;
    final isCurrentAdmin =
        user.id == ServiceLocator.instance.authUseCases.currentUserId();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            fullName.isEmpty ? 'Sans nom' : fullName,
            style: TextStyle(
              color: t.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _InfoBlock(label: 'Email', value: user.email),
          if (deleteMode) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.beetRed,
                  foregroundColor: Colors.white,
                ),
                onPressed: isCurrentAdmin ? null : onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(
                  isCurrentAdmin
                      ? 'Suppression impossible'
                      : 'Supprimer ce compte',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AdminCreateUserCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final bool isCreating;
  final VoidCallback onCreate;

  const AdminCreateUserCard({
    super.key,
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.isCreating,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.borderColor),
            ),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.green,
              ),
              title: Text(
                'Ajouter un compte utilisateur',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Seul l\'admin peut creer les comptes. Le mot de passe est defini par l\'utilisateur via email.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          AdminIndependentInputBlock(
            controller: lastNameCtrl,
            label: 'Nom',
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 12),
          AdminIndependentInputBlock(
            controller: firstNameCtrl,
            label: 'Prenom',
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 12),
          AdminIndependentInputBlock(
            controller: emailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Requis';
              if (!v.contains('@')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: isCreating ? null : onCreate,
              icon: isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_rounded),
              label: Text(isCreating ? 'Creation...' : 'Creer le compte'),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminIndependentInputBlock extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AdminIndependentInputBlock({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.borderColor),
      ),
      child: AdminInputField(
        controller: controller,
        label: label,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: t.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: t.mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class AdminInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AdminInputField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
