import 'package:flutter/material.dart';
import 'package:kiwo/app/di/service_locator.dart';
import 'package:kiwo/features/home/presentation/screens/dashboard_screen.dart';
import 'package:kiwo/features/home/presentation/screens/elevage_screen.dart';
import 'package:kiwo/features/gestion_des_iot_devices/presentation/screens/index.dart';
import 'package:kiwo/features/profile/presentation/screens/profile_screen.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';
import 'package:kiwo/shared/presentation/theme/kiwo_theme.dart';
import 'package:kiwo/shared/presentation/theme/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authUseCases = ServiceLocator.instance.authUseCases;
  int _currentIndex = 0;
  final Map<int, Widget?> _pagesCache = {};

  @override
  void initState() {
    super.initState();
    _ensurePageBuilt(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;
    final children = List<Widget>.generate(
      4,
      (index) => _pagesCache[index] ?? const SizedBox.shrink(),
    );

    return KiwoThemeWrapper(
      child: Scaffold(
        backgroundColor: theme.bgColor,
        appBar: AppBar(
          backgroundColor: theme.headerColor,
          foregroundColor: theme.textColor,
          elevation: 0,
          titleSpacing: 20,
          title: _buildAppBarTitle(theme),
          actions: [
            IconButton(
              tooltip: 'Deconnexion',
              onPressed: _authUseCases.signOut,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: IndexedStack(index: _currentIndex, children: children),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: theme.headerColor,
          indicatorColor: AppColors.green.withValues(alpha: 0.16),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (index) {
            setState(() {
              _ensurePageBuilt(index);
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Tableau',
            ),
            NavigationDestination(
              icon: Text('🐔', style: TextStyle(fontSize: 20)),
              selectedIcon: Text('🐔', style: TextStyle(fontSize: 20)),
              label: 'Elevage',
            ),
            NavigationDestination(
              icon: Icon(Icons.sensors_outlined),
              selectedIcon: Icon(Icons.sensors_rounded),
              label: 'Objets IoT',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  void _ensurePageBuilt(int index) {
    if (_pagesCache.containsKey(index) && _pagesCache[index] != null) return;
    _pagesCache[index] = _createPage(index);
  }

  Widget _createPage(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const ElevageScreen();
      case 2:
        return const IotObjectsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Gestion de l\'elevage';
      case 2:
        return 'Objets IoT';
      case 3:
        return 'Profil';
      case 0:
      default:
        return '';
    }
  }

  Widget _buildAppBarTitle(ThemeProvider theme) {
    if (_currentIndex == 0) {
      return Text(
        'Kiwo',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: theme.textColor,
        ),
      );
    }

    return Text(
      _titleForIndex(_currentIndex),
      style: const TextStyle(fontWeight: FontWeight.w800),
    );
  }
}
