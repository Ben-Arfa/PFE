import 'package:flutter/material.dart';
import 'package:kiwo/features/gestion_des_types_des_volailles/presentation/screens/types_screen.dart';
import 'package:kiwo/features/gestions_des_batiments/presentation/screens/buildings_screen.dart';
import 'package:kiwo/features/gestions_des_lots_des_volailles/presentation/screens/lots_screen.dart';
import 'package:kiwo/features/saisie_quotidienne/presentation/screens/saisie_home_screen.dart';
import 'package:kiwo/features/suivi_des_vaccinations/presentation/screens/vaccinations_screen.dart';

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF5DB83D).withValues(alpha: 0.98),
                    const Color(0xFF8FD14E).withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5DB83D).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        child: Text('🐔', style: TextStyle(fontSize: 28)),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Gestion de l\'élevage',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Accès rapide aux sections principales',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Structure de l\'élevage',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.6,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ActionCard(
                      icon: Icons.category_rounded,
                      title: 'Types',
                      subtitle: 'Créer & structurer',
                      gradient: const [Color(0xFF5DB83D), Color(0xFF8FD14E)],
                      onTap: () =>
                          setState(() => _section = _ElevageSection.types),
                    ),
                    _ActionCard(
                      icon: Icons.apartment_rounded,
                      title: 'Bâtiments',
                      subtitle: 'Organiser',
                      gradient: const [Color(0xFF4A9B6F), Color(0xFF7FBFA0)],
                      onTap: () =>
                          setState(() => _section = _ElevageSection.buildings),
                    ),
                    _ActionCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'Lots',
                      subtitle: 'Gérer',
                      gradient: const [Color(0xFF8A5A2B), Color(0xFFD39A5D)],
                      onTap: () =>
                          setState(() => _section = _ElevageSection.lots),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Suivi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.6,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ActionCard(
                      icon: Icons.event_note_rounded,
                      title: 'Saisie',
                      subtitle: 'Quotidienne',
                      gradient: const [Color(0xFF2563EB), Color(0xFF60A5FA)],
                      onTap: () =>
                          setState(() => _section = _ElevageSection.saisie),
                    ),
                    _ActionCard(
                      icon: Icons.vaccines_rounded,
                      title: 'Santé',
                      subtitle: 'Vaccinations',
                      gradient: const [Color(0xFF8B5CF6), Color(0xFFB794F4)],
                      onTap: () => setState(
                        () => _section = _ElevageSection.vaccinations,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: Colors.white, size: 16),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
