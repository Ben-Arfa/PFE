import 'package:flutter/material.dart';
import 'package:kiwo/app/di/service_locator.dart';
import 'package:kiwo/features/profile/presentation/screens/profile_screen.dart';
import 'package:kiwo/features/home/presentation/screens/elevage_screen.dart';
import 'package:kiwo/features/home/presentation/screens/iot_objects_screen.dart';
import 'package:kiwo/features/home/presentation/screens/dashboard_screen.dart';
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
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    // children for IndexedStack: use cached widgets when available, otherwise placeholders
    final children = List<Widget>.generate(
      4,
      (i) => _pagesCache[i] ?? const SizedBox.shrink(),
    );

    return KiwoThemeWrapper(
      child: Scaffold(
        backgroundColor: t.bgColor,
        appBar: AppBar(
          backgroundColor: t.headerColor,
          foregroundColor: t.textColor,
          elevation: 0,
          titleSpacing: 20,
          title: _buildAppBarTitle(t),
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
          backgroundColor: t.headerColor,
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

  @override
  void initState() {
    super.initState();
    // prebuild the first page for faster first display
    _ensurePageBuilt(0);
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
