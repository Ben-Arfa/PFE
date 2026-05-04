import 'package:flutter/material.dart';
import 'package:kiwo/features/gestion_des_types_des_volailles/presentation/screens/types_screen.dart';
import 'package:kiwo/features/gestions_des_batiments/presentation/screens/buildings_screen.dart';
import 'package:kiwo/features/gestions_des_lots_des_volailles/presentation/screens/lots_screen.dart';
import 'package:kiwo/features/saisie_quotidienne/presentation/screens/saisie_home_screen.dart';
import 'package:kiwo/features/suivi_des_vaccinations/presentation/screens/vaccinations_screen.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';

class ElevageScreen extends StatefulWidget {
  const ElevageScreen({super.key});

  @override
  State<ElevageScreen> createState() => _ElevageScreenState();
}

enum _ElevageSection { menu, types, buildings, lots, saisie, vaccinations }

class _ElevageScreenState extends State<ElevageScreen> {
  _ElevageSection _section = _ElevageSection.menu;

  @override
  Widget build(BuildContext context) {
    final child = switch (_section) {
      _ElevageSection.menu => _buildMenu(context),
      _ElevageSection.types => const TypesScreen(),
      _ElevageSection.buildings => const BuildingsScreen(),
      _ElevageSection.lots => const LotsScreen(),
      _ElevageSection.saisie => SaisieHomeScreen(),
      _ElevageSection.vaccinations => const VaccinationsScreen(
        showShell: false,
      ),
    };

    return PopScope(
      canPop: _section == _ElevageSection.menu,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _section == _ElevageSection.menu) {
          return;
        }

        setState(() => _section = _ElevageSection.menu);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Expanded(child: child)],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.green.withValues(alpha: 0.95),
                  AppColors.green.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.pets, size: 32, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gestion de l\'élevage',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accède rapidement aux actions principales de ton élevage',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _ActionButton(
                  icon: Icons.list_alt_outlined,
                  title: 'Types de volailles',
                  subtitle: 'Créer et gérer les types',
                  onTap: () => setState(() => _section = _ElevageSection.types),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.apartment_outlined,
                  title: 'Bâtiments',
                  subtitle: 'Créer et gérer les bâtiments',
                  onTap: () =>
                      setState(() => _section = _ElevageSection.buildings),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.inventory_2_outlined,
                  title: 'Lots de volailles',
                  subtitle: 'Gérer vos lots',
                  onTap: () => setState(() => _section = _ElevageSection.lots),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.event_note_outlined,
                  title: 'Saisie quotidiennes',
                  subtitle: 'Observations quotidiennes',
                  onTap: () =>
                      setState(() => _section = _ElevageSection.saisie),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.vaccines_outlined,
                  title: 'Santé & Vaccinations',
                  subtitle: 'Gérer les vaccinations',
                  onTap: () =>
                      setState(() => _section = _ElevageSection.vaccinations),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
