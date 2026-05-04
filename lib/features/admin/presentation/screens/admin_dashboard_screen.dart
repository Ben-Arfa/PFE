import 'package:flutter/material.dart';
import 'package:kiwo/app/di/service_locator.dart';
import 'package:kiwo/features/admin/domain/entities/admin_user.dart';
import 'package:kiwo/features/admin/presentation/widgets/admin_dashboard_widgets.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';
import 'package:kiwo/shared/presentation/theme/kiwo_theme.dart';
import 'package:kiwo/shared/presentation/theme/theme_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminUseCases = ServiceLocator.instance.adminUseCases;
  final _authUseCases = ServiceLocator.instance.authUseCases;

  final _createFormKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _isCreating = false;
  String _accountsMode = 'initial';

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_createFormKey.currentState!.validate()) return;

    setState(() => _isCreating = true);
    try {
      await _adminUseCases.createUserAccount(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );

      _firstNameCtrl.clear();
      _lastNameCtrl.clear();
      _emailCtrl.clear();

      if (mounted) {
        _showSnack(
          'Compte créé. Un email de définition de mot de passe a été envoyé.',
          AppColors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          e.toString().replaceFirst('Exception: ', ''),
          AppColors.beetRed,
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _deleteUser(AdminUser user) async {
    final userId = user.id;
    final fullName = user.fullName;
    final email = user.email;
    if (userId.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer cet utilisateur ?'),
          content: Text(
            'Cette action supprimera les donnees utilisateur dans Firestore.\n\n'
            'Compte: ${fullName.isEmpty ? email : fullName}\n'
            'Email: $email',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.beetRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      await _adminUseCases.deleteUserAccount(userId: userId);
      if (mounted) {
        _showSnack('Utilisateur supprime avec succes.', AppColors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          e.toString().replaceFirst('Exception: ', ''),
          AppColors.beetRed,
        );
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;

    return PopScope(
      canPop: _accountsMode == 'initial',
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _accountsMode == 'initial') {
          return;
        }

        setState(() => _accountsMode = 'initial');
      },
      child: KiwoThemeWrapper(
        child: Scaffold(
          backgroundColor: t.bgColor,
          appBar: AppBar(
            backgroundColor: t.headerColor,
            foregroundColor: t.textColor,
            title: const Text(
              'Administration KIWO',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                tooltip: 'Deconnexion',
                onPressed: _authUseCases.signOut,
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_accountsMode == 'initial') ...[
                    const AdminDashboardIntroCard(),
                    const SizedBox(height: 16),
                    AdminShortcutCard(
                      borderColor: AppColors.green,
                      backgroundColor: AppColors.green.withValues(alpha: 0.14),
                      icon: Icons.person_add_rounded,
                      title: 'Ajouter utilisateur',
                      description: 'Creer un nouveau compte',
                      onTap: () => setState(() => _accountsMode = 'create'),
                      iconColor: AppColors.green,
                      iconSize: 32,
                      verticalPadding: 18,
                    ),
                    const SizedBox(height: 16),
                    AdminShortcutCard(
                      borderColor: AppColors.beetRed,
                      backgroundColor: AppColors.beetRed.withValues(
                        alpha: 0.08,
                      ),
                      icon: Icons.delete_outline_rounded,
                      title: 'Supprimer utilisateur',
                      description: 'Supprimer un compte existant',
                      onTap: () => setState(() => _accountsMode = 'delete'),
                      iconColor: AppColors.beetRed,
                      iconSize: 32,
                      verticalPadding: 18,
                    ),
                    const SizedBox(height: 16),
                    AdminShortcutCard(
                      borderColor: t.borderColor,
                      backgroundColor: t.cardColor,
                      icon: Icons.list_alt_rounded,
                      title: 'Consulter la liste',
                      description:
                          'Voir tous les comptes en cartes independantes',
                      onTap: () => setState(() => _accountsMode = 'list'),
                      iconColor: AppColors.green,
                      iconSize: 48,
                      verticalPadding: 20,
                    ),
                  ],
                  if (_accountsMode == 'create') ...[
                    AdminCreateUserCard(
                      formKey: _createFormKey,
                      firstNameCtrl: _firstNameCtrl,
                      lastNameCtrl: _lastNameCtrl,
                      emailCtrl: _emailCtrl,
                      isCreating: _isCreating,
                      onCreate: _createUser,
                    ),
                  ] else if (_accountsMode == 'list') ...[
                    const SizedBox(height: 12),
                    _buildUsersList(),
                  ] else if (_accountsMode == 'delete') ...[
                    const SizedBox(height: 12),
                    _buildUsersList(deleteMode: true),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList({bool deleteMode = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminUserListHeader(),
        const SizedBox(height: 16),
        StreamBuilder<List<AdminUser>>(
          stream: _adminUseCases.watchRecentUsers(limit: 40),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data ?? const [];

            if (users.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Aucun utilisateur trouve.')),
              );
            }

            return Column(
              children: [
                for (int i = 0; i < users.length; i++) ...[
                  AdminUserInfoCard(
                    user: users[i],
                    deleteMode: deleteMode,
                    onDelete: () => _deleteUser(users[i]),
                  ),
                  if (i != users.length - 1) const SizedBox(height: 16),
                ],
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ],
    );
  }
}
