// lib/features/home/screens/home_screen.dart
// Orchestrateur — 4 onglets : Dashboard / Config / Suivi / Profil

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:kiwo/core/app_colors.dart';
import 'package:kiwo/core/theme_provider.dart';
import 'package:kiwo/core/kiwo_theme.dart';
import 'package:kiwo/core/models.dart';
import 'package:kiwo/features/auth/services/auth_service.dart';
import 'package:kiwo/features/auth/services/config_service.dart';
import 'package:kiwo/features/farm_config/tabs/dashboard_tab.dart';
import 'package:kiwo/features/farm_config/tabs/config_tab.dart';
import 'package:kiwo/features/farm_config/tabs/profile_tab.dart';
import 'package:kiwo/features/tracking/screens/tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _authService = AuthService();
  final _configService = ConfigService();

  Map<String, dynamic>? _userData;
  bool _loadingData = true;
  bool _loadingConfig = true;

  int _tab = 0;

  SystemState _sysState = SystemState.idle;
  final SystemConfig _cfg = SystemConfig();

  int _wizardStep = 0;

  // Controllers pour les champs texte du wizard
  final _farmNameCtrl = TextEditingController();
  final _poultryTypeCtrl = TextEditingController();
  final _objectiveCtrl = TextEditingController();
  final _birdCtrl = TextEditingController();
  final _surfaceCtrl = TextEditingController();

  final Map<String, bool> _equipState = {
    'ventilation': false,
    'heating': false,
    'lighting': false,
    'feeding': false,
    'watering': false,
  };

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  // ════════════════════════════════════════════════════════════════
  // CYCLE DE VIE
  // ════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    ThemeProvider.instance.addListener(_onThemeChanged);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();

    _init();
  }

  Future<void> _init() async => Future.wait([_loadUserData(), _loadConfig()]);

  Future<void> _loadUserData() async {
    final data = await _authService.getUserData();
    if (mounted)
      setState(() {
        _userData = data;
        _loadingData = false;
      });
  }

  Future<void> _loadConfig() async {
    final data = await _configService.loadConfig();
    if (!mounted) return;
    setState(() {
      if (data != null) {
        _cfg.fromMap(data);
        // Restaure les controllers texte
        _farmNameCtrl.text = _cfg.farmName;
        _poultryTypeCtrl.text = _cfg.poultryType;
        _objectiveCtrl.text = _cfg.objective;
        _birdCtrl.text = _cfg.birdCount > 0 ? _cfg.birdCount.toString() : '';
        _surfaceCtrl.text = _cfg.surfaceM2 > 0 ? _cfg.surfaceM2.toString() : '';
        if (_cfg.systemRunning) {
          _sysState = SystemState.running;
          _applyEquipState();
        }
      }
      _loadingConfig = false;
    });
  }

  @override
  void dispose() {
    ThemeProvider.instance.removeListener(_onThemeChanged);
    _anim.dispose();
    _farmNameCtrl.dispose();
    _poultryTypeCtrl.dispose();
    _objectiveCtrl.dispose();
    _birdCtrl.dispose();
    _surfaceCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  // LOGIQUE SYSTÈME
  // ════════════════════════════════════════════════════════════════

  void _applyEquipState() {
    _equipState['ventilation'] = _cfg.autoVentilation;
    _equipState['heating'] = _cfg.autoHeating;
    _equipState['lighting'] = _cfg.autoLighting;
    _equipState['feeding'] = _cfg.autoFeeding;
    _equipState['watering'] = _cfg.autoWatering;
  }

  Future<void> _saveConfig() async => _configService.saveConfig(_cfg.toMap());

  bool _sensorOk(String id, double value) {
    if (!_cfg.isConfigured) return true;
    switch (id) {
      case 'temp':
        return value >= _cfg.tempMin && value <= _cfg.tempMax;
      case 'hum':
        return value >= _cfg.humMin && value <= _cfg.humMax;
      case 'water':
        return value >= _cfg.waterAlertPct;
      case 'food':
        return value >= _cfg.foodAlertPct;
      case 'co2':
        return value <= _cfg.co2Max;
      case 'ammo':
        return value <= _cfg.ammoniacMax;
    }
    return true;
  }

  // Callback unique pour tous les changements de champ du wizard
  void _onFieldChange(String field, dynamic val) {
    setState(() {
      switch (field) {
        case 'farmName':
          _cfg.farmName = val as String;
          break;
        case 'poultryType':
          _cfg.poultryType = val as String;
          break;
        case 'objective':
          _cfg.objective = val as String;
          break;
        case 'birdCount':
          _cfg.birdCount = val as int;
          break;
        case 'surfaceM2':
          _cfg.surfaceM2 = val as double;
          break;
        case 'tempMin':
          _cfg.tempMin = val as double;
          break;
        case 'tempMax':
          _cfg.tempMax = val as double;
          break;
        case 'humMin':
          _cfg.humMin = val as double;
          break;
        case 'humMax':
          _cfg.humMax = val as double;
          break;
        case 'co2Max':
          _cfg.co2Max = val as double;
          break;
        case 'ammoniacMax':
          _cfg.ammoniacMax = val as double;
          break;
        case 'lightHours':
          _cfg.lightHours = val as double;
          break;
        case 'waterAlertPct':
          _cfg.waterAlertPct = val as double;
          break;
        case 'foodAlertPct':
          _cfg.foodAlertPct = val as double;
          break;
        case 'autoVentilation':
          _cfg.autoVentilation = val as bool;
          break;
        case 'autoHeating':
          _cfg.autoHeating = val as bool;
          break;
        case 'autoLighting':
          _cfg.autoLighting = val as bool;
          break;
        case 'autoFeeding':
          _cfg.autoFeeding = val as bool;
          break;
        case 'autoWatering':
          _cfg.autoWatering = val as bool;
          break;
      }
    });
    // Sauvegarde automatique à chaque changement
    _configService.saveConfig(_cfg.toMap());
  }

  Future<void> _launchSystem() async {
    setState(() {
      _sysState = SystemState.running;
      _cfg.systemRunning = true;
      _applyEquipState();
      _tab = 0;
    });
    await _saveConfig();
    _snack('Système lancé avec succès !', AppColors.green);
  }

  Future<void> _stopSystem() async {
    setState(() {
      _sysState = SystemState.idle;
      _cfg.systemRunning = false;
      _equipState.updateAll((_, __) => false);
    });
    await _saveConfig();
    _snack('Système arrêté.', AppColors.muted);
  }

  Future<void> _pauseSystem() async {
    setState(() {
      _sysState = _sysState == SystemState.paused
          ? SystemState.running
          : SystemState.paused;
      _cfg.systemRunning = _sysState == SystemState.running;
    });
    await _saveConfig();
  }

  // ════════════════════════════════════════════════════════════════
  // LOGIQUE PROFIL
  // ════════════════════════════════════════════════════════════════

  Future<void> _saveName(String firstName, String lastName) async {
    try {
      await _authService.updateUserData(
        firstName: firstName,
        lastName: lastName,
      );
      await _loadUserData();
      _snack('Nom mis à jour !', AppColors.green);
    } catch (_) {
      _snack('Erreur lors de la mise à jour.', AppColors.beetRed);
    }
  }

  Future<void> _savePassword(String current, String next) async {
    await _authService.updatePassword(
      currentPassword: current,
      newPassword: next,
    );
    _snack('Mot de passe mis à jour !', AppColors.green);
  }

  // ════════════════════════════════════════════════════════════════
  // HELPERS UI
  // ════════════════════════════════════════════════════════════════

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: AppColors.cream,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Déconnexion ?',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Le système continuera à fonctionner. Tu pourras reprendre le contrôle à la prochaine connexion.',
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _authService.signOut();
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _sysColor => switch (_sysState) {
    SystemState.running => AppColors.green,
    SystemState.paused => AppColors.green.withOpacity(0.1),
    SystemState.alert => AppColors.beetRed,
    _ => AppColors.muted,
  };

  String get _sysLabel => switch (_sysState) {
    SystemState.running => 'SYSTÈME ACTIF',
    SystemState.paused => 'EN PAUSE',
    SystemState.alert => 'ALERTE',
    _ => 'INACTIF',
  };

  IconData get _sysIcon => switch (_sysState) {
    SystemState.running => Icons.play_circle_fill_rounded,
    SystemState.paused => Icons.pause_circle_filled_rounded,
    SystemState.alert => Icons.error_rounded,
    _ => Icons.radio_button_unchecked_rounded,
  };

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final fullName =
        '${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}'
            .trim();
    final firstName = _userData?['firstName'] ?? '';
    final isLoading = _loadingData || _loadingConfig;
    final theme = ThemeProvider.instance;

    return KiwoThemeWrapper(
      child: Scaffold(
        backgroundColor: theme.bgColor,
        bottomNavigationBar: isLoading ? null : _buildBottomNav(theme),
        body: isLoading
            ? _buildSplash()
            : FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _buildHeader(firstName, theme),
                        Expanded(child: _buildBody(fullName, user)),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSplash() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 16),
        const Text(
          'KIWO',
          style: TextStyle(
            color: AppColors.dark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 24),
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.green,
            strokeWidth: 2.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Chargement de votre élevage…',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _buildHeader(String firstName, ThemeProvider theme) => Container(
    decoration: BoxDecoration(
      color: theme.headerColor,
      border: Border(
        bottom: BorderSide(color: AppColors.green.withOpacity(0.15), width: 1),
      ),
    ),
    padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'KIWO',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _sysColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: _sysColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(_sysIcon, color: _sysColor, size: 10),
                  const SizedBox(width: 5),
                  Text(
                    _sysLabel,
                    style: TextStyle(
                      color: _sysColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _showSignOutDialog,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.green,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildBottomNav(ThemeProvider theme) {
    const labels = ['Tableau de bord', 'Configuration', 'Suivi', 'Profil'];
    const icons = [
      Icons.monitor_heart_rounded,
      Icons.tune_rounded,
      Icons.bar_chart_rounded,
      Icons.person_rounded,
    ];
    return Container(
      decoration: BoxDecoration(
        color: theme.navColor,
        border: Border(
          top: BorderSide(color: AppColors.green.withOpacity(0.15), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(4, (i) {
              final active = _tab == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: active ? AppColors.green : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[i],
                          size: 20,
                          color: active
                              ? AppColors.green
                              : theme.navTextInactive,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[i],
                          style: TextStyle(
                            color: active
                                ? AppColors.green
                                : theme.navTextInactive,
                            fontSize: 9,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(String fullName, User? user) {
    return IndexedStack(
      index: _tab,
      children: [
        DashboardTab(
          cfg: _cfg,
          sysState: _sysState,
          equipState: _equipState,
          sensorOk: _sensorOk,
          onLaunch: _launchSystem,
          onPause: _pauseSystem,
          onStop: _stopSystem,
          onEquipToggle: (key, val) => setState(() => _equipState[key] = val),
          onGoToConfig: () => setState(() => _tab = 1),
        ),
        ConfigTab(
          cfg: _cfg,
          sysState: _sysState,
          wizardStep: _wizardStep,
          farmNameCtrl: _farmNameCtrl,
          poultryTypeCtrl: _poultryTypeCtrl,
          objectiveCtrl: _objectiveCtrl,
          birdCtrl: _birdCtrl,
          surfaceCtrl: _surfaceCtrl,
          onStepChange: (s) => setState(() => _wizardStep = s),
          onFieldChange: _onFieldChange,
          onLaunch: _launchSystem,
        ),
        TrackingScreen(cfg: _cfg),
        ProfileTab(
          fullName: fullName,
          user: user,
          onSaveName: _saveName,
          onSavePassword: _savePassword,
          onSignOut: _showSignOutDialog,
        ),
      ],
    );
  }
}
