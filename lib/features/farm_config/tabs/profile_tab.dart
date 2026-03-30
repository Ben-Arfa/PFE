// lib/features/farm_config/tabs/profile_tab.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/theme_provider.dart';
import '../../../core/kiwo_theme.dart';
import '../widgets/shared_widgets.dart';

class ProfileTab extends StatelessWidget {
  final String fullName;
  final User? user;
  final void Function(String firstName, String lastName) onSaveName;
  final void Function(String current, String next) onSavePassword;
  final VoidCallback onSignOut;

  const ProfileTab({
    required this.fullName,
    required this.user,
    required this.onSaveName,
    required this.onSavePassword,
    required this.onSignOut,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return KiwoThemeWrapper(
      child: _ProfileTabBody(
        fullName: fullName,
        user: user,
        onSaveName: onSaveName,
        onSavePassword: onSavePassword,
        onSignOut: onSignOut,
      ),
    );
  }
}

class _ProfileTabBody extends StatelessWidget {
  final String fullName;
  final User? user;
  final void Function(String, String) onSaveName;
  final void Function(String, String) onSavePassword;
  final VoidCallback onSignOut;

  const _ProfileTabBody({
    required this.fullName,
    required this.user,
    required this.onSaveName,
    required this.onSavePassword,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileAvatar(fullName: fullName, email: user?.email ?? ''),
          const SizedBox(height: 24),

          _SectionLabel('INFORMATIONS'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: t.surfaceColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: t.borderColor),
            ),
            child: Column(
              children: [
                _EditableRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nom complet',
                  value: fullName.isNotEmpty ? fullName : '—',
                  onTap: () => _showEditNameSheet(context),
                ),
                Divider(height: 1, color: t.borderColor),
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user?.email ?? '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          _SectionLabel('PARAMÈTRES'),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.lock_outline_rounded,
            title: 'Mot de passe',
            sub: 'Modifier le mot de passe',
            color: AppColors.blue,
            onTap: () => _showEditPasswordSheet(context),
          ),
          const SizedBox(height: 8),
          const _DarkModeToggle(),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: onSignOut,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.green, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SE DÉCONNECTER',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.logout_rounded, color: AppColors.green, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameSheet(BuildContext context) {
    final parts = fullName.split(' ');
    final firstCtrl = TextEditingController(
      text: parts.isNotEmpty ? parts[0] : '',
    );
    final lastCtrl = TextEditingController(
      text: parts.length > 1 ? parts.sublist(1).join(' ') : '',
    );
    bool saving = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => KiwoBottomSheet(
          title: 'Modifier le nom',
          icon: Icons.person_outline_rounded,
          child: Column(
            children: [
              SheetField('PRÉNOM', firstCtrl, Icons.badge_outlined),
              const SizedBox(height: 14),
              SheetField('NOM', lastCtrl, Icons.badge_outlined),
              const SizedBox(height: 24),
              SheetSaveButton(
                'ENREGISTRER',
                loading: saving,
                onTap: () async {
                  if (firstCtrl.text.trim().isEmpty ||
                      lastCtrl.text.trim().isEmpty) {
                    return;
                  }
                  setSheet(() => saving = true);
                  try {
                    onSaveName(firstCtrl.text.trim(), lastCtrl.text.trim());
                    if (ctx.mounted) Navigator.pop(ctx);
                  } finally {
                    setSheet(() => saving = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditPasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool saving = false;
    String? error;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => KiwoBottomSheet(
          title: 'Modifier le mot de passe',
          icon: Icons.lock_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetField(
                'MOT DE PASSE ACTUEL',
                currentCtrl,
                Icons.lock_outline_rounded,
                obscure: true,
              ),
              const SizedBox(height: 14),
              SheetField(
                'NOUVEAU MOT DE PASSE',
                newCtrl,
                Icons.lock_rounded,
                obscure: true,
              ),
              const SizedBox(height: 14),
              SheetField(
                'CONFIRMER',
                confirmCtrl,
                Icons.lock_reset_rounded,
                obscure: true,
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(
                  error!,
                  style: const TextStyle(
                    color: AppColors.beetRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SheetSaveButton(
                'ENREGISTRER',
                loading: saving,
                onTap: () async {
                  if (currentCtrl.text.isEmpty || newCtrl.text.isEmpty) return;
                  if (newCtrl.text != confirmCtrl.text) {
                    setSheet(() => error = 'Ne correspondent pas.');
                    return;
                  }
                  if (newCtrl.text.length < 6) {
                    setSheet(() => error = 'Minimum 6 caractères.');
                    return;
                  }
                  setSheet(() {
                    saving = true;
                    error = null;
                  });
                  try {
                    onSavePassword(currentCtrl.text, newCtrl.text);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (_) {
                    setSheet(() => error = 'Mot de passe actuel incorrect.');
                  } finally {
                    setSheet(() => saving = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widgets privés ───────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: ThemeProvider.instance.mutedColor,
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    ),
  );
}

class _ProfileAvatar extends StatelessWidget {
  final String fullName, email;
  const _ProfileAvatar({required this.fullName, required this.email});
  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Center(
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            fullName.isNotEmpty ? fullName : 'Éleveur',
            style: TextStyle(
              color: t.textColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(email, style: TextStyle(color: t.mutedColor, fontSize: 12)),
        ],
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final VoidCallback onTap;
  const _EditableRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: t.mutedColor, size: 17),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: t.mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: t.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit_rounded, color: t.mutedColor, size: 14),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: t.mutedColor, size: 17),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: t.mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: t.textColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final Color color;
  final VoidCallback? onTap;
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.sub,
    required this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.surfaceColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: t.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: t.textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(color: t.mutedColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: t.mutedColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DarkModeToggle extends StatefulWidget {
  const _DarkModeToggle();
  @override
  State<_DarkModeToggle> createState() => _DarkModeToggleState();
}

class _DarkModeToggleState extends State<_DarkModeToggle> {
  @override
  void initState() {
    super.initState();
    ThemeProvider.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    ThemeProvider.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: t.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              t.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: AppColors.green,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.isDark ? 'Mode sombre' : 'Mode clair',
                  style: TextStyle(
                    color: t.textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  t.isDark
                      ? 'Basculer en mode clair'
                      : 'Basculer en mode sombre',
                  style: TextStyle(color: t.mutedColor, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ThemeProvider.instance.toggle(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 46,
              height: 26,
              decoration: BoxDecoration(
                color: t.isDark
                    ? AppColors.green
                    : AppColors.muted.withOpacity(0.25),
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: t.isDark
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
