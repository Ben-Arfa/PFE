import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/config_service.dart';

// ─────────────────────────────────────────────────────────────────
// MODÈLES
// ─────────────────────────────────────────────────────────────────

class PoultryType {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final double tempMin, tempMax;
  final double humMin, humMax;
  final double co2Max, ammoniacMax;
  final double lightHours;
  final double waterAlertPct, foodAlertPct;

  const PoultryType({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.tempMin,
    required this.tempMax,
    required this.humMin,
    required this.humMax,
    required this.co2Max,
    required this.ammoniacMax,
    required this.lightHours,
    required this.waterAlertPct,
    required this.foodAlertPct,
  });
}

const List<PoultryType> kPoultryTypes = [
  PoultryType(
    id: 'broiler',
    name: 'Poulet de chair',
    emoji: '🐔',
    description: 'Croissance rapide, élevage intensif pour la viande.',
    tempMin: 20,
    tempMax: 32,
    humMin: 50,
    humMax: 70,
    co2Max: 3000,
    ammoniacMax: 20,
    lightHours: 18,
    waterAlertPct: 25,
    foodAlertPct: 25,
  ),
  PoultryType(
    id: 'layer',
    name: 'Poule pondeuse',
    emoji: '🥚',
    description: 'Production d\'œufs, sensible à la lumière.',
    tempMin: 18,
    tempMax: 28,
    humMin: 45,
    humMax: 65,
    co2Max: 2500,
    ammoniacMax: 15,
    lightHours: 16,
    waterAlertPct: 20,
    foodAlertPct: 20,
  ),
  PoultryType(
    id: 'turkey',
    name: 'Dinde',
    emoji: '🦃',
    description: 'Élevage pour viande, bâtiments plus spacieux.',
    tempMin: 16,
    tempMax: 28,
    humMin: 40,
    humMax: 60,
    co2Max: 2800,
    ammoniacMax: 18,
    lightHours: 14,
    waterAlertPct: 25,
    foodAlertPct: 25,
  ),
  PoultryType(
    id: 'duck',
    name: 'Canard',
    emoji: '🦆',
    description: 'Humidité plus élevée, résistant au froid.',
    tempMin: 15,
    tempMax: 26,
    humMin: 55,
    humMax: 80,
    co2Max: 2500,
    ammoniacMax: 15,
    lightHours: 12,
    waterAlertPct: 30,
    foodAlertPct: 20,
  ),
  PoultryType(
    id: 'guinea',
    name: 'Pintade',
    emoji: '🐦',
    description: 'Semi-extensif, très actif, viande fine.',
    tempMin: 18,
    tempMax: 30,
    humMin: 45,
    humMax: 65,
    co2Max: 2500,
    ammoniacMax: 15,
    lightHours: 14,
    waterAlertPct: 20,
    foodAlertPct: 20,
  ),
  PoultryType(
    id: 'quail',
    name: 'Caille',
    emoji: '🐤',
    description: 'Élevage compact pour œufs et viande de luxe.',
    tempMin: 20,
    tempMax: 30,
    humMin: 50,
    humMax: 70,
    co2Max: 2000,
    ammoniacMax: 12,
    lightHours: 16,
    waterAlertPct: 20,
    foodAlertPct: 20,
  ),
];

PoultryType? poultryById(String? id) {
  if (id == null) return null;
  try {
    return kPoultryTypes.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────
class SystemConfig {
  PoultryType? poultryType;
  int birdCount = 0;
  double surfaceM2 = 0;
  double tempMin = 20;
  double tempMax = 32;
  double humMin = 50;
  double humMax = 70;
  double co2Max = 3000;
  double ammoniacMax = 20;
  double lightHours = 16;
  double waterAlertPct = 25;
  double foodAlertPct = 25;
  bool autoVentilation = true;
  bool autoHeating = true;
  bool autoLighting = true;
  bool autoFeeding = false;
  bool autoWatering = false;
  bool systemRunning = false; // ← état du système persisté

  // Sérialise vers Firestore
  Map<String, dynamic> toMap() => {
    'poultryTypeId': poultryType?.id,
    'birdCount': birdCount,
    'surfaceM2': surfaceM2,
    'tempMin': tempMin,
    'tempMax': tempMax,
    'humMin': humMin,
    'humMax': humMax,
    'co2Max': co2Max,
    'ammoniacMax': ammoniacMax,
    'lightHours': lightHours,
    'waterAlertPct': waterAlertPct,
    'foodAlertPct': foodAlertPct,
    'autoVentilation': autoVentilation,
    'autoHeating': autoHeating,
    'autoLighting': autoLighting,
    'autoFeeding': autoFeeding,
    'autoWatering': autoWatering,
    'systemRunning': systemRunning,
  };

  // Désérialise depuis Firestore
  void fromMap(Map<String, dynamic> m) {
    poultryType = poultryById(m['poultryTypeId']);
    birdCount = (m['birdCount'] ?? 0).toInt();
    surfaceM2 = (m['surfaceM2'] ?? 0).toDouble();
    tempMin = (m['tempMin'] ?? 20).toDouble();
    tempMax = (m['tempMax'] ?? 32).toDouble();
    humMin = (m['humMin'] ?? 50).toDouble();
    humMax = (m['humMax'] ?? 70).toDouble();
    co2Max = (m['co2Max'] ?? 3000).toDouble();
    ammoniacMax = (m['ammoniacMax'] ?? 20).toDouble();
    lightHours = (m['lightHours'] ?? 16).toDouble();
    waterAlertPct = (m['waterAlertPct'] ?? 25).toDouble();
    foodAlertPct = (m['foodAlertPct'] ?? 25).toDouble();
    autoVentilation = m['autoVentilation'] ?? true;
    autoHeating = m['autoHeating'] ?? true;
    autoLighting = m['autoLighting'] ?? true;
    autoFeeding = m['autoFeeding'] ?? false;
    autoWatering = m['autoWatering'] ?? false;
    systemRunning = m['systemRunning'] ?? false;
  }
}

enum SystemState { idle, running, paused, alert }

// ─────────────────────────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────────────────────────
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
  bool _loadingConfig = true; // ← chargement config Firestore

  int _tab = 0;
  SystemState _sysState = SystemState.idle;
  final SystemConfig _cfg = SystemConfig();

  int _wizardStep = 0;
  final _birdCtrl = TextEditingController();
  final _surfaceCtrl = TextEditingController();

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  static const kCream = Color(0xFFFFF8ED);
  static const kOrange = Color(0xFFFF5B05);
  static const kYellow = Color(0xFFFFF24D);
  static const kGreen = Color(0xFF4B7B28);
  static const kPink = Color(0xFFF4B8C0);
  static const kBeetRed = Color(0xFFAB1717);
  static const kDark = Color(0xFF1C1C1A);
  static const kMuted = Color(0xFF7A7060);
  static const kBlue = Color(0xFFA1B4C8);

  final List<Map<String, dynamic>> _sensors = [
    {
      'id': 'temp',
      'label': 'TEMPÉRATURE',
      'value': 24.5,
      'unit': '°C',
      'icon': Icons.thermostat_rounded,
      'color': Color(0xFFFF5B05),
      'min': 0.0,
      'max': 50.0,
    },
    {
      'id': 'hum',
      'label': 'HUMIDITÉ',
      'value': 68.0,
      'unit': '%',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFFA1B4C8),
      'min': 0.0,
      'max': 100.0,
    },
    {
      'id': 'water',
      'label': "NIV. D'EAU",
      'value': 42.0,
      'unit': '%',
      'icon': Icons.opacity_rounded,
      'color': Color(0xFF4B7B28),
      'min': 0.0,
      'max': 100.0,
    },
    {
      'id': 'food',
      'label': 'NOURRITURE',
      'value': 18.0,
      'unit': '%',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFAB1717),
      'min': 0.0,
      'max': 100.0,
    },
    {
      'id': 'co2',
      'label': 'CO₂',
      'value': 1800.0,
      'unit': 'ppm',
      'icon': Icons.air_rounded,
      'color': Color(0xFF7A7060),
      'min': 0.0,
      'max': 5000.0,
    },
    {
      'id': 'ammo',
      'label': 'AMMONIAC',
      'value': 12.0,
      'unit': 'ppm',
      'icon': Icons.science_rounded,
      'color': Color(0xFF4B7B28),
      'min': 0.0,
      'max': 50.0,
    },
  ];

  final Map<String, bool> _equipState = {
    'ventilation': false,
    'heating': false,
    'lighting': false,
    'feeding': false,
    'watering': false,
  };

  // ── Init ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
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

  /// Charge en parallèle les données utilisateur ET la config persistée
  Future<void> _init() async {
    await Future.wait([_loadUserData(), _loadConfig()]);
  }

  Future<void> _loadUserData() async {
    final data = await _authService.getUserData();
    if (mounted)
      setState(() {
        _userData = data;
        _loadingData = false;
      });
  }

  /// Charge la config depuis Firestore et restaure l'état du système
  Future<void> _loadConfig() async {
    final data = await _configService.loadConfig();
    if (mounted) {
      setState(() {
        if (data != null) {
          _cfg.fromMap(data);
          // Restaure les champs texte
          _birdCtrl.text = _cfg.birdCount > 0 ? _cfg.birdCount.toString() : '';
          _surfaceCtrl.text = _cfg.surfaceM2 > 0
              ? _cfg.surfaceM2.toString()
              : '';
          // Restaure l'état du système
          if (_cfg.systemRunning) {
            _sysState = SystemState.running;
            _applyEquipState();
          }
        }
        _loadingConfig = false;
      });
    }
  }

  void _applyEquipState() {
    _equipState['ventilation'] = _cfg.autoVentilation;
    _equipState['heating'] = _cfg.autoHeating;
    _equipState['lighting'] = _cfg.autoLighting;
    _equipState['feeding'] = _cfg.autoFeeding;
    _equipState['watering'] = _cfg.autoWatering;
  }

  /// Sauvegarde la config dans Firestore après chaque modification
  Future<void> _saveConfig() async {
    await _configService.saveConfig(_cfg.toMap());
  }

  @override
  void dispose() {
    _anim.dispose();
    _birdCtrl.dispose();
    _surfaceCtrl.dispose();
    super.dispose();
  }

  // ── Système ───────────────────────────────────────────────────────
  bool _sensorOk(Map<String, dynamic> s) {
    if (_cfg.poultryType == null) return true;
    final v = s['value'] as double;
    switch (s['id']) {
      case 'temp':
        return v >= _cfg.tempMin && v <= _cfg.tempMax;
      case 'hum':
        return v >= _cfg.humMin && v <= _cfg.humMax;
      case 'water':
        return v >= _cfg.waterAlertPct;
      case 'food':
        return v >= _cfg.foodAlertPct;
      case 'co2':
        return v <= _cfg.co2Max;
      case 'ammo':
        return v <= _cfg.ammoniacMax;
    }
    return true;
  }

  String _sensorStatus(Map<String, dynamic> s) =>
      _sensorOk(s) ? 'Normal' : 'Alerte';

  Color get _sysColor {
    switch (_sysState) {
      case SystemState.running:
        return kGreen;
      case SystemState.paused:
        return kYellow;
      case SystemState.alert:
        return kBeetRed;
      default:
        return kMuted;
    }
  }

  String get _sysLabel {
    switch (_sysState) {
      case SystemState.running:
        return 'SYSTÈME ACTIF';
      case SystemState.paused:
        return 'EN PAUSE';
      case SystemState.alert:
        return 'ALERTE';
      default:
        return 'INACTIF';
    }
  }

  IconData get _sysIcon {
    switch (_sysState) {
      case SystemState.running:
        return Icons.play_circle_fill_rounded;
      case SystemState.paused:
        return Icons.pause_circle_filled_rounded;
      case SystemState.alert:
        return Icons.error_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  Future<void> _launchSystem() async {
    setState(() {
      _sysState = SystemState.running;
      _cfg.systemRunning = true;
      _applyEquipState();
      _tab = 0;
    });
    await _saveConfig(); // ← persiste l'état "en cours"
    _snack('Système lancé avec succès !', kGreen);
  }

  Future<void> _stopSystem() async {
    setState(() {
      _sysState = SystemState.idle;
      _cfg.systemRunning = false;
      _equipState.updateAll((k, v) => false);
    });
    await _saveConfig(); // ← persiste l'état "arrêté"
    _snack('Système arrêté.', kMuted);
  }

  Future<void> _pauseSystem() async {
    setState(() {
      _sysState = _sysState == SystemState.paused
          ? SystemState.running
          : SystemState.paused;
      // On ne persiste pas "paused" — à la reconnexion on reprend "running"
      _cfg.systemRunning = _sysState == SystemState.running;
    });
    await _saveConfig();
  }

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: kCream, fontWeight: FontWeight.w700),
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
        backgroundColor: kCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Déconnexion ?',
          style: TextStyle(color: kDark, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Le système continuera à fonctionner. Tu pourras reprendre le contrôle à la prochaine connexion.',
          style: TextStyle(color: kMuted, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: kMuted, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _authService.signOut();
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: kOrange, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = _userData?['firstName'] ?? '';
    final fullName =
        '${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}'
            .trim();

    final isLoading = _loadingData || _loadingConfig;

    return Scaffold(
      backgroundColor: kCream,
      body: isLoading
          ? _buildSplash()
          : FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(firstName),
                      _stripe(),
                      _buildTabBar(),
                      Expanded(child: _buildBody(fullName, user)),
                      _stripe(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Écran de chargement pendant la récupération config
  Widget _buildSplash() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: kOrange,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.egg_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'KIWO',
            style: TextStyle(
              color: kDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: kOrange, strokeWidth: 2.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Chargement de votre élevage…',
            style: TextStyle(color: kMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────────
  Widget _buildHeader(String firstName) {
    return Container(
      color: kDark,
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
                  color: kOrange,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.egg_alt_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'KIWO',
                style: TextStyle(
                  color: kCream,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: kOrange,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stripe() => Row(
    children: [
      Expanded(child: Container(height: 4, color: kOrange)),
      Expanded(child: Container(height: 4, color: kYellow)),
      Expanded(child: Container(height: 4, color: kGreen)),
      Expanded(child: Container(height: 4, color: kPink)),
    ],
  );

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _tabItem('TABLEAU DE BORD', 0, Icons.monitor_heart_rounded),
          _tabItem('CONFIGURATION', 1, Icons.tune_rounded),
          _tabItem('PROFIL', 2, Icons.person_rounded),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index, IconData icon) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? kOrange : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: active ? kOrange : kMuted),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: active ? kDark : kMuted,
                fontSize: 9.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(String fullName, User? user) {
    switch (_tab) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildConfiguration();
      case 2:
        return _buildProfil(fullName, user);
      default:
        return _buildDashboard();
    }
  }

  // ════════════════════════════════════════════════════════════════
  // DASHBOARD
  // ════════════════════════════════════════════════════════════════
  Widget _buildDashboard() {
    if (_cfg.poultryType == null) return _buildEmptyDashboard();

    final alerts = _sensors.where((s) => !_sensorOk(s)).toList();
    if (_sysState == SystemState.running && alerts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _sysState != SystemState.alert)
          setState(() => _sysState = SystemState.alert);
      });
    } else if (_sysState == SystemState.alert && alerts.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _sysState = SystemState.running);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _systemStatusCard(),
          const SizedBox(height: 18),
          if (alerts.isNotEmpty) ...[
            ...alerts.map((s) => _alertBanner(s)),
            const SizedBox(height: 8),
          ],
          _sectionLabel('CAPTEURS EN DIRECT'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: _sensors.length,
            itemBuilder: (_, i) => _sensorCard(_sensors[i]),
          ),
          const SizedBox(height: 22),
          _sectionLabel('ÉQUIPEMENTS'),
          const SizedBox(height: 12),
          _equipmentPanel(),
          const SizedBox(height: 22),
          _sectionLabel('MON ÉLEVAGE'),
          const SizedBox(height: 12),
          _farmSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildEmptyDashboard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: kOrange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('🐔', style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun élevage configuré',
              style: TextStyle(
                color: kDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure ton type de volaille pour démarrer l\'automatisation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kMuted, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => setState(() => _tab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CONFIGURER MON ÉLEVAGE',
                      style: TextStyle(
                        color: kCream,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: kYellow, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _systemStatusCard() {
    final isIdle = _sysState == SystemState.idle;
    final isPaused = _sysState == SystemState.paused;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _sysColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          _cfg.poultryType!.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _cfg.poultryType!.name,
                              style: const TextStyle(
                                color: kCream,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${_cfg.birdCount} sujets · ${_cfg.surfaceM2.toStringAsFixed(0)} m²',
                              style: TextStyle(
                                color: kCream.withOpacity(0.45),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (isIdle)
                    _ctrlBtn(
                      'LANCER',
                      kGreen,
                      Icons.play_arrow_rounded,
                      _launchSystem,
                    ),
                  if (!isIdle) ...[
                    _ctrlBtn(
                      isPaused ? 'REPRENDRE' : 'PAUSE',
                      isPaused ? kGreen : kYellow,
                      isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      _pauseSystem,
                    ),
                    const SizedBox(height: 8),
                    _ctrlBtn(
                      'ARRÊTER',
                      kBeetRed,
                      Icons.stop_rounded,
                      _stopSystem,
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (!isIdle) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withOpacity(0.07)),
            const SizedBox(height: 12),
            Row(
              children: [
                _statPill(
                  'Ventil.',
                  _equipState['ventilation']! ? 'ON' : 'OFF',
                  _equipState['ventilation']! ? kGreen : kMuted,
                ),
                const SizedBox(width: 6),
                _statPill(
                  'Chauff.',
                  _equipState['heating']! ? 'ON' : 'OFF',
                  _equipState['heating']! ? kOrange : kMuted,
                ),
                const SizedBox(width: 6),
                _statPill(
                  'Lumière',
                  _equipState['lighting']! ? 'ON' : 'OFF',
                  _equipState['lighting']! ? kYellow : kMuted,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _ctrlBtn(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kCream, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: kCream,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _statPill(String label, String val, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(4),
    ),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 10),
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              color: kCream.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: val,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );

  Widget _alertBanner(Map<String, dynamic> s) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: kBeetRed.withOpacity(0.07),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: kBeetRed.withOpacity(0.25)),
    ),
    child: Row(
      children: [
        Icon(s['icon'] as IconData, color: kBeetRed, size: 15),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${s['label']} hors seuil : ${s['value']}${s['unit']}',
            style: const TextStyle(
              color: kBeetRed,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Icon(Icons.warning_amber_rounded, color: kBeetRed, size: 15),
      ],
    ),
  );

  Widget _sensorCard(Map<String, dynamic> s) {
    final color = s['color'] as Color;
    final ok = _sensorOk(s);
    final pct =
        ((s['value'] as double) - (s['min'] as double)) /
        ((s['max'] as double) - (s['min'] as double));
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: kDark,
        borderRadius: BorderRadius.circular(8),
        border: ok
            ? null
            : Border.all(color: kBeetRed.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(s['icon'] as IconData, color: color, size: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (ok ? kGreen : kBeetRed).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _sensorStatus(s),
                  style: TextStyle(
                    color: ok ? kGreen : kBeetRed,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (s['value'] as double).toStringAsFixed(
                      s['unit'] == 'ppm' ? 0 : 1,
                    ),
                    style: const TextStyle(
                      color: kCream,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 2),
                    child: Text(
                      s['unit'] as String,
                      style: TextStyle(
                        color: kCream.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0),
                  minHeight: 3,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation(ok ? color : kBeetRed),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s['label'] as String,
                style: TextStyle(
                  color: kCream.withOpacity(0.3),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _equipmentPanel() {
    final equip = [
      {
        'key': 'ventilation',
        'label': 'Ventilation',
        'icon': Icons.air_outlined,
        'color': kBlue,
      },
      {
        'key': 'heating',
        'label': 'Chauffage',
        'icon': Icons.local_fire_department_rounded,
        'color': kOrange,
      },
      {
        'key': 'lighting',
        'label': 'Éclairage',
        'icon': Icons.light_mode_rounded,
        'color': kYellow,
      },
      {
        'key': 'feeding',
        'label': 'Alimentation',
        'icon': Icons.restaurant_rounded,
        'color': kGreen,
      },
      {
        'key': 'watering',
        'label': 'Abreuvement',
        'icon': Icons.water_drop_outlined,
        'color': kBlue,
      },
    ];
    return Column(
      children: equip.map((e) {
        final key = e['key'] as String;
        final isOn = _equipState[key] ?? false;
        final color = e['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kDark.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              Icon(
                e['icon'] as IconData,
                color: isOn ? color : kMuted,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e['label'] as String,
                      style: TextStyle(
                        color: isOn ? kDark : kMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _sysState == SystemState.idle
                          ? 'Système inactif'
                          : isOn
                          ? 'En fonctionnement'
                          : 'Arrêté',
                      style: TextStyle(
                        color: isOn
                            ? kGreen.withOpacity(0.7)
                            : kMuted.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _sysState == SystemState.idle
                    ? null
                    : () => setState(() => _equipState[key] = !isOn),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 46,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isOn ? kGreen : kMuted.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    alignment: isOn
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
      }).toList(),
    );
  }

  Widget _farmSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kDark.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.thermostat_rounded,
            'Temp. cible',
            '${_cfg.tempMin.toStringAsFixed(0)}–${_cfg.tempMax.toStringAsFixed(0)} °C',
            kOrange,
          ),
          _divider(),
          _infoRow(
            Icons.water_drop_rounded,
            'Humidité cible',
            '${_cfg.humMin.toStringAsFixed(0)}–${_cfg.humMax.toStringAsFixed(0)} %',
            kBlue,
          ),
          _divider(),
          _infoRow(
            Icons.wb_sunny_rounded,
            'Éclairage/jour',
            '${_cfg.lightHours.toStringAsFixed(0)} h',
            kYellow,
          ),
          _divider(),
          _infoRow(
            Icons.groups_rounded,
            'Effectif',
            '${_cfg.birdCount} sujets',
            kGreen,
          ),
          _divider(),
          _infoRow(
            Icons.square_foot_rounded,
            'Superficie',
            '${_cfg.surfaceM2.toStringAsFixed(0)} m²',
            kMuted,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: kMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: kDark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );

  // ════════════════════════════════════════════════════════════════
  // CONFIGURATION — WIZARD
  // ════════════════════════════════════════════════════════════════
  Widget _buildConfiguration() {
    // Si config déjà complète, montrer un résumé modifiable
    if (_cfg.poultryType != null && _sysState != SystemState.idle) {
      return _buildConfigSummaryEditable();
    }
    return Column(
      children: [
        _wizardProgress(),
        Expanded(child: _wizardStepContent()),
      ],
    );
  }

  /// Résumé de la config avec bouton "Modifier" quand le système tourne
  Widget _buildConfigSummaryEditable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  _cfg.poultryType!.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cfg.poultryType!.name,
                        style: const TextStyle(
                          color: kCream,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${_cfg.birdCount} sujets · ${_cfg.surfaceM2.toStringAsFixed(0)} m²',
                        style: TextStyle(
                          color: kCream.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACTIF',
                    style: TextStyle(
                      color: kGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Info : arrêter pour modifier
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kYellow.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kYellow.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: kYellow,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pour modifier la configuration, arrête d\'abord le système depuis le tableau de bord.',
                    style: TextStyle(
                      color: kDark.withOpacity(0.7),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('PARAMÈTRES ACTIFS'),
          const SizedBox(height: 12),
          _farmSummaryCard(),
          const SizedBox(height: 16),
          _sectionLabel('AUTOMATISMES ACTIFS'),
          const SizedBox(height: 12),
          _automationSummary(),
        ],
      ),
    );
  }

  Widget _automationSummary() {
    final items = [
      {
        'label': 'Ventilation',
        'val': _cfg.autoVentilation,
        'icon': Icons.air_outlined,
        'color': kBlue,
      },
      {
        'label': 'Chauffage',
        'val': _cfg.autoHeating,
        'icon': Icons.local_fire_department_rounded,
        'color': kOrange,
      },
      {
        'label': 'Éclairage',
        'val': _cfg.autoLighting,
        'icon': Icons.light_mode_rounded,
        'color': kYellow,
      },
      {
        'label': 'Alimentation',
        'val': _cfg.autoFeeding,
        'icon': Icons.restaurant_rounded,
        'color': kGreen,
      },
      {
        'label': 'Abreuvement',
        'val': _cfg.autoWatering,
        'icon': Icons.water_drop_outlined,
        'color': kBlue,
      },
    ];
    return Column(
      children: items.map((a) {
        final on = a['val'] as bool;
        final color = a['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kDark.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              Icon(a['icon'] as IconData, color: on ? color : kMuted, size: 17),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  a['label'] as String,
                  style: TextStyle(
                    color: on ? kDark : kMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: (on ? kGreen : kMuted).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  on ? 'ACTIVÉ' : 'DÉSACTIVÉ',
                  style: TextStyle(
                    color: on ? kGreen : kMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _wizardProgress() {
    final steps = ['Volaille', 'Bâtiment', 'Seuils', 'Automatismes'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final done = i < _wizardStep;
          final active = i == _wizardStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 3,
                        decoration: BoxDecoration(
                          color: done || active
                              ? kOrange
                              : kDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        steps[i],
                        style: TextStyle(
                          color: active
                              ? kOrange
                              : done
                              ? kGreen
                              : kMuted,
                          fontSize: 9,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _wizardStepContent() {
    switch (_wizardStep) {
      case 0:
        return _stepPoultry();
      case 1:
        return _stepBuilding();
      case 2:
        return _stepThresholds();
      case 3:
        return _stepAutomation();
      default:
        return _stepPoultry();
    }
  }

  // ── Étape 0 ──────────────────────────────────────────────────────
  Widget _stepPoultry() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle(
            'Quel type de volaille ?',
            'Sélectionne ton élevage pour charger les paramètres adaptés.',
          ),
          const SizedBox(height: 18),
          ...kPoultryTypes.map((p) {
            final sel = _cfg.poultryType?.id == p.id;
            return GestureDetector(
              onTap: () => setState(() {
                _cfg.poultryType = p;
                _cfg.tempMin = p.tempMin;
                _cfg.tempMax = p.tempMax;
                _cfg.humMin = p.humMin;
                _cfg.humMax = p.humMax;
                _cfg.co2Max = p.co2Max;
                _cfg.ammoniacMax = p.ammoniacMax;
                _cfg.lightHours = p.lightHours;
                _cfg.waterAlertPct = p.waterAlertPct;
                _cfg.foodAlertPct = p.foodAlertPct;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: sel ? kOrange.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: sel ? kOrange : kDark.withOpacity(0.08),
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(p.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: TextStyle(
                              color: sel ? kOrange : kDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.description,
                            style: TextStyle(
                              color: kMuted,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (sel)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: kOrange,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          _nextBtn(
            'Suivant',
            _cfg.poultryType != null,
            () => setState(() => _wizardStep = 1),
          ),
        ],
      ),
    );
  }

  // ── Étape 1 ──────────────────────────────────────────────────────
  Widget _stepBuilding() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle(
            'Ton bâtiment',
            'Renseigne les informations sur ton installation.',
          ),
          const SizedBox(height: 20),
          _label('NOMBRE DE VOLAILLES'),
          const SizedBox(height: 7),
          _textField(
            controller: _birdCtrl,
            hint: 'ex: 500',
            icon: Icons.groups_rounded,
            suffix: 'sujets',
            keyboard: TextInputType.number,
            onChanged: (v) {
              _cfg.birdCount = int.tryParse(v) ?? 0;
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          _label('SUPERFICIE DU BÂTIMENT'),
          const SizedBox(height: 7),
          _textField(
            controller: _surfaceCtrl,
            hint: 'ex: 200',
            icon: Icons.square_foot_rounded,
            suffix: 'm²',
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) {
              _cfg.surfaceM2 = double.tryParse(v) ?? 0;
              setState(() {});
            },
          ),
          if (_cfg.birdCount > 0 && _cfg.surfaceM2 > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.07),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: kGreen.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate_rounded, color: kGreen, size: 15),
                  const SizedBox(width: 10),
                  Text(
                    'Densité : ${(_cfg.birdCount / _cfg.surfaceM2).toStringAsFixed(1)} sujets/m²',
                    style: const TextStyle(
                      color: kGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              _backBtn(() => setState(() => _wizardStep = 0)),
              const SizedBox(width: 12),
              Expanded(
                child: _nextBtn(
                  'Suivant',
                  _cfg.birdCount > 0 && _cfg.surfaceM2 > 0,
                  () => setState(() => _wizardStep = 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Étape 2 ──────────────────────────────────────────────────────
  Widget _stepThresholds() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle(
            'Seuils des capteurs',
            'Pré-remplis selon ton élevage. Ajuste si besoin.',
          ),
          const SizedBox(height: 18),
          _thresholdCard(
            icon: Icons.thermostat_rounded,
            label: 'TEMPÉRATURE',
            unit: '°C',
            color: kOrange,
            minVal: _cfg.tempMin,
            maxVal: _cfg.tempMax,
            absMin: 0,
            absMax: 50,
            onMinChanged: (v) => setState(() => _cfg.tempMin = v),
            onMaxChanged: (v) => setState(() => _cfg.tempMax = v),
          ),
          const SizedBox(height: 10),
          _thresholdCard(
            icon: Icons.water_drop_rounded,
            label: 'HUMIDITÉ',
            unit: '%',
            color: kBlue,
            minVal: _cfg.humMin,
            maxVal: _cfg.humMax,
            absMin: 0,
            absMax: 100,
            onMinChanged: (v) => setState(() => _cfg.humMin = v),
            onMaxChanged: (v) => setState(() => _cfg.humMax = v),
          ),
          const SizedBox(height: 10),
          _singleThresholdCard(
            icon: Icons.air_rounded,
            label: 'CO₂ MAX',
            unit: 'ppm',
            color: kMuted,
            value: _cfg.co2Max,
            min: 500,
            max: 5000,
            onChanged: (v) => setState(() => _cfg.co2Max = v),
            description: 'Alerte déclenchée au-dessus de ce seuil.',
          ),
          const SizedBox(height: 10),
          _singleThresholdCard(
            icon: Icons.science_rounded,
            label: 'AMMONIAC MAX',
            unit: 'ppm',
            color: kGreen,
            value: _cfg.ammoniacMax,
            min: 0,
            max: 50,
            onChanged: (v) => setState(() => _cfg.ammoniacMax = v),
            description: 'Seuil critique pour la santé des volailles.',
          ),
          const SizedBox(height: 10),
          _singleThresholdCard(
            icon: Icons.wb_sunny_rounded,
            label: 'ÉCLAIRAGE / JOUR',
            unit: 'h',
            color: kYellow,
            value: _cfg.lightHours,
            min: 0,
            max: 24,
            onChanged: (v) => setState(() => _cfg.lightHours = v),
            description: 'Heures de lumière par jour.',
          ),
          const SizedBox(height: 10),
          _singleThresholdCard(
            icon: Icons.opacity_rounded,
            label: "ALERTE NIVEAU D'EAU",
            unit: '%',
            color: kGreen,
            value: _cfg.waterAlertPct,
            min: 0,
            max: 100,
            onChanged: (v) => setState(() => _cfg.waterAlertPct = v),
            description: 'Alerte si le niveau descend en dessous.',
          ),
          const SizedBox(height: 10),
          _singleThresholdCard(
            icon: Icons.restaurant_rounded,
            label: 'ALERTE NOURRITURE',
            unit: '%',
            color: kBeetRed,
            value: _cfg.foodAlertPct,
            min: 0,
            max: 100,
            onChanged: (v) => setState(() => _cfg.foodAlertPct = v),
            description: 'Alerte si le stock descend en dessous.',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _backBtn(() => setState(() => _wizardStep = 1)),
              const SizedBox(width: 12),
              Expanded(
                child: _nextBtn(
                  'Suivant',
                  true,
                  () => setState(() => _wizardStep = 3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Étape 3 ──────────────────────────────────────────────────────
  Widget _stepAutomation() {
    final automations = [
      {
        'key': 'autoVentilation',
        'label': 'Ventilation automatique',
        'desc': 'Déclenche si CO₂ ou NH₃ dépasse le seuil.',
        'icon': Icons.air_outlined,
        'color': kBlue,
      },
      {
        'key': 'autoHeating',
        'label': 'Chauffage automatique',
        'desc': 'Active si la température passe sous le seuil min.',
        'icon': Icons.local_fire_department_rounded,
        'color': kOrange,
      },
      {
        'key': 'autoLighting',
        'label': 'Éclairage automatique',
        'desc': 'Gère le cycle lumineux selon la durée configurée.',
        'icon': Icons.light_mode_rounded,
        'color': kYellow,
      },
      {
        'key': 'autoFeeding',
        'label': 'Alimentation automatique',
        'desc': 'Distribution quand le niveau nourriture est bas.',
        'icon': Icons.restaurant_rounded,
        'color': kGreen,
      },
      {
        'key': 'autoWatering',
        'label': 'Abreuvement automatique',
        'desc': 'Remplit l\'abreuvoir si niveau eau bas.',
        'icon': Icons.water_drop_outlined,
        'color': kBlue,
      },
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle(
            'Automatismes',
            'Active les équipements à piloter automatiquement.',
          ),
          const SizedBox(height: 18),
          ...automations.map((a) {
            final key = a['key'] as String;
            final val = key == 'autoVentilation'
                ? _cfg.autoVentilation
                : key == 'autoHeating'
                ? _cfg.autoHeating
                : key == 'autoLighting'
                ? _cfg.autoLighting
                : key == 'autoFeeding'
                ? _cfg.autoFeeding
                : _cfg.autoWatering;
            final color = a['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: val ? color.withOpacity(0.3) : kDark.withOpacity(0.07),
                  width: val ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: val
                          ? color.withOpacity(0.12)
                          : kDark.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      a['icon'] as IconData,
                      color: val ? color : kMuted,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['label'] as String,
                          style: TextStyle(
                            color: val ? kDark : kMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a['desc'] as String,
                          style: TextStyle(
                            color: kMuted.withOpacity(0.8),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() {
                      if (key == 'autoVentilation')
                        _cfg.autoVentilation = !_cfg.autoVentilation;
                      else if (key == 'autoHeating')
                        _cfg.autoHeating = !_cfg.autoHeating;
                      else if (key == 'autoLighting')
                        _cfg.autoLighting = !_cfg.autoLighting;
                      else if (key == 'autoFeeding')
                        _cfg.autoFeeding = !_cfg.autoFeeding;
                      else
                        _cfg.autoWatering = !_cfg.autoWatering;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 46,
                      height: 26,
                      decoration: BoxDecoration(
                        color: val ? kGreen : kMuted.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        alignment: val
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
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              _backBtn(() => setState(() => _wizardStep = 2)),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _launchSystem,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: kGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: kCream, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'LANCER LE SYSTÈME',
                          style: TextStyle(
                            color: kCream,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // PROFIL
  // ════════════════════════════════════════════════════════════════
  Widget _buildProfil(String fullName, User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ─────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: kOrange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: kCream,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  fullName.isNotEmpty ? fullName : 'Éleveur',
                  style: const TextStyle(
                    color: kDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Informations ────────────────────────────────────────────
          _sectionLabel('INFORMATIONS'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kDark.withOpacity(0.07)),
            ),
            child: Column(
              children: [
                _editableRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nom complet',
                  value: fullName.isNotEmpty ? fullName : '—',
                  onTap: () => _showEditNameSheet(fullName),
                ),
                _divider(),
                _infoRow(
                  Icons.email_outlined,
                  'Email',
                  user?.email ?? '—',
                  kDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Paramètres ──────────────────────────────────────────────
          _sectionLabel('PARAMÈTRES'),
          const SizedBox(height: 12),
          _settingTile(
            Icons.lock_outline_rounded,
            'Mot de passe',
            'Modifier le mot de passe',
            kBlue,
            onTap: () => _showEditPasswordSheet(),
          ),
          const SizedBox(height: 8),
          _settingTile(
            Icons.notifications_outlined,
            'Notifications',
            'Alertes capteurs et système',
            kOrange,
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // ── Déconnexion ─────────────────────────────────────────────
          GestureDetector(
            onTap: _showSignOutDialog,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: kOrange, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SE DÉCONNECTER',
                    style: TextStyle(
                      color: kOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.logout_rounded, color: kOrange, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ligne éditable ────────────────────────────────────────────────
  Widget _editableRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: kMuted, size: 17),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: kMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: kDark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_rounded, color: kMuted, size: 14),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet : modifier nom ───────────────────────────────────
  void _showEditNameSheet(String currentName) {
    final parts = currentName.split(' ');
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
        builder: (ctx, setSheet) => _sheet(
          title: 'Modifier le nom',
          icon: Icons.person_outline_rounded,
          child: Column(
            children: [
              _sheetField('PRÉNOM', firstCtrl, Icons.badge_outlined),
              const SizedBox(height: 14),
              _sheetField('NOM', lastCtrl, Icons.badge_outlined),
              const SizedBox(height: 24),
              _sheetSaveBtn('ENREGISTRER', saving, () async {
                if (firstCtrl.text.trim().isEmpty ||
                    lastCtrl.text.trim().isEmpty)
                  return;
                setSheet(() => saving = true);
                try {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    await _authService.updateUserData(
                      firstName: firstCtrl.text.trim(),
                      lastName: lastCtrl.text.trim(),
                    );
                    await _loadUserData();
                    if (mounted) {
                      Navigator.pop(context);
                      _snack('Nom mis à jour !', kGreen);
                    }
                  }
                } catch (e) {
                  if (mounted)
                    _snack('Erreur lors de la mise à jour.', kBeetRed);
                } finally {
                  setSheet(() => saving = false);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom sheet : modifier email ─────────────────────────────────
  // ── Bottom sheet : modifier mot de passe ──────────────────────────
  void _showEditPasswordSheet() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => _sheet(
          title: 'Modifier le mot de passe',
          icon: Icons.lock_outline_rounded,
          child: Column(
            children: [
              _sheetField(
                'MOT DE PASSE ACTUEL',
                currentCtrl,
                Icons.lock_outline_rounded,
                obscure: true,
              ),
              const SizedBox(height: 14),
              _sheetField(
                'NOUVEAU MOT DE PASSE',
                newCtrl,
                Icons.lock_rounded,
                obscure: true,
              ),
              const SizedBox(height: 14),
              _sheetField(
                'CONFIRMER',
                confirmCtrl,
                Icons.lock_reset_rounded,
                obscure: true,
              ),
              const SizedBox(height: 24),
              _sheetSaveBtn('ENREGISTRER', saving, () async {
                if (currentCtrl.text.isEmpty || newCtrl.text.isEmpty) return;
                if (newCtrl.text != confirmCtrl.text) {
                  _snack('Les mots de passe ne correspondent pas.', kBeetRed);
                  return;
                }
                if (newCtrl.text.length < 6) {
                  _snack('Minimum 6 caractères.', kBeetRed);
                  return;
                }
                setSheet(() => saving = true);
                try {
                  await _authService.updatePassword(
                    currentPassword: currentCtrl.text,
                    newPassword: newCtrl.text,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _snack('Mot de passe mis à jour !', kGreen);
                  }
                } catch (e) {
                  if (mounted)
                    _snack('Mot de passe actuel incorrect.', kBeetRed);
                } finally {
                  setSheet(() => saving = false);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Template bottom sheet ─────────────────────────────────────────
  Widget _sheet({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: kCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kDark.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Titre
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: kOrange, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: kDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }

  Widget _sheetField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboard,
          style: const TextStyle(
            color: kDark,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: kMuted, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: kDark.withOpacity(0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: kDark.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kOrange, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sheetSaveBtn(String label, bool loading, VoidCallback onTap) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: loading ? kMuted.withOpacity(0.3) : kDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: kCream,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: kCream,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.check_rounded, color: kYellow, size: 17),
                  ],
                ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // WIDGETS RÉUTILISABLES
  // ─────────────────────────────────────────────────────────────────
  Widget _stepTitle(String t, String s) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        t,
        style: const TextStyle(
          color: kDark,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 4),
      Text(s, style: TextStyle(color: kMuted, fontSize: 13, height: 1.5)),
    ],
  );

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: kMuted,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    ),
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: kMuted,
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 2.5,
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String suffix,
    required TextInputType keyboard,
    required ValueChanged<String> onChanged,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    onChanged: onChanged,
    style: const TextStyle(
      color: kDark,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: kMuted.withOpacity(0.5), fontSize: 14),
      prefixIcon: Icon(icon, color: kMuted, size: 18),
      suffixText: suffix,
      suffixStyle: const TextStyle(color: kMuted, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: kDark.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: kDark.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: kOrange, width: 2),
      ),
    ),
  );

  Widget _thresholdCard({
    required IconData icon,
    required String label,
    required String unit,
    required Color color,
    required double minVal,
    required double maxVal,
    required double absMin,
    required double absMax,
    required ValueChanged<double> onMinChanged,
    required ValueChanged<double> onMaxChanged,
  }) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: kDark.withOpacity(0.07)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: kDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sliderRow('MIN', minVal, absMin, absMax, unit, color, (v) {
          if (v < maxVal - 1) onMinChanged(v);
        }),
        const SizedBox(height: 4),
        _sliderRow('MAX', maxVal, absMin, absMax, unit, color, (v) {
          if (v > minVal + 1) onMaxChanged(v);
        }),
      ],
    ),
  );

  Widget _singleThresholdCard({
    required IconData icon,
    required String label,
    required String unit,
    required Color color,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required String description,
  }) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: kDark.withOpacity(0.07)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: kDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _sliderRow('', value, min, max, unit, color, onChanged),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: kMuted.withOpacity(0.7), fontSize: 10.5),
        ),
      ],
    ),
  );

  Widget _sliderRow(
    String slabel,
    double val,
    double min,
    double max,
    String unit,
    Color color,
    ValueChanged<double> onChange,
  ) => Row(
    children: [
      if (slabel.isNotEmpty)
        SizedBox(
          width: 28,
          child: Text(
            slabel,
            style: TextStyle(
              color: kMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      Expanded(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: kDark.withOpacity(0.08),
            overlayColor: color.withOpacity(0.1),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: val.clamp(min, max),
            min: min,
            max: max,
            divisions: (max - min).toInt().clamp(1, 200),
            onChanged: onChange,
          ),
        ),
      ),
      Container(
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            '${val.toStringAsFixed(0)}$unit',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _nextBtn(String label, bool enabled, VoidCallback onTap) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: enabled ? kOrange : kMuted.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: enabled ? kCream : kMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: enabled ? kYellow : kMuted,
                size: 17,
              ),
            ],
          ),
        ),
      );

  Widget _backBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: kDark.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.arrow_back_rounded, color: kDark, size: 18),
    ),
  );

  Widget _settingTile(
    IconData icon,
    String title,
    String sub,
    Color color, {
    VoidCallback? onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kDark.withOpacity(0.07)),
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
                  style: const TextStyle(
                    color: kDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(sub, style: const TextStyle(color: kMuted, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: kMuted, size: 20),
        ],
      ),
    ),
  );

  Widget _divider() =>
      Divider(color: kDark.withOpacity(0.06), height: 1, indent: 16);
}
