import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiwo/core/theme_provider.dart';
import 'package:kiwo/features/home/presentation/screens/alerts_screen.dart';
import 'package:kiwo/features/home/presentation/screens/notifications_screen.dart';
import 'package:kiwo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kiwo/features/profile/data/services/profile_service.dart';
import 'package:kiwo/features/profile/domain/entities/user_profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ProfileRepositoryImpl _profileRepository = ProfileRepositoryImpl(
    ProfileService(),
  );

  CollectionReference<Map<String, dynamic>>? _userCollection(String name) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(name);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? _watch(String name) {
    return _userCollection(name)?.snapshots();
  }

  Stream<List<Map<String, dynamic>>> _watchUpcomingVaccinations() {
    final collection = _userCollection('notifications');
    if (collection == null) return const Stream.empty();

    return collection
        .orderBy('scheduledAt', descending: false)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          return snapshot.docs
              .map((doc) => doc.data())
              .where((data) {
                final status = data['status'] as String?;
                final scheduledAt = (data['scheduledAt'] as Timestamp?)
                    ?.toDate();
                if (scheduledAt == null) return false;
                if (status != 'scheduled' && status != 'received') return false;
                return scheduledAt.isAfter(now) || _sameDay(scheduledAt, now);
              })
              .take(4)
              .toList();
        });
  }

  static bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        final mainColumn = SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DashboardHeader(
                profileRepository: _profileRepository,
                theme: theme,
              ),
              const SizedBox(height: 14),
              _QuickActions(theme: theme),
              const SizedBox(height: 18),
              _OverviewPanel(
                theme: theme,
                buildingsStream: _watch('buildings'),
                lotsStream: _watch('lots'),
                poultryTypesStream: _watch('poultryTypes'),
                notificationsStream: _watch('notifications'),
              ),
              const SizedBox(height: 18),
              _SectionHeading(
                title: 'Etat des batiments',
                actionLabel: 'Temps reel',
                theme: theme,
              ),
              const SizedBox(height: 10),
              _EnvironmentPanel(
                theme: theme,
                buildingsStream: _watch('buildings'),
                devicesStream: _watch('iot_devices'),
              ),
              const SizedBox(height: 18),
              _SectionHeading(
                title: 'Lots a surveiller',
                actionLabel: 'Mortalite',
                theme: theme,
              ),
              const SizedBox(height: 10),
              _RiskPanel(theme: theme, lotsStream: _watch('lots')),
              const SizedBox(height: 18),
              _SectionHeading(
                title: 'Vaccinations a venir',
                actionLabel: 'Planning',
                theme: theme,
              ),
              const SizedBox(height: 10),
              _UpcomingVaccinationsPanel(
                theme: theme,
                stream: _watchUpcomingVaccinations(),
              ),
            ],
          ),
        );

        if (!isWide) return mainColumn;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: mainColumn),
            const SizedBox(width: 18),
            SizedBox(
              width: 360,
              child: _RightSummaryPanel(
                theme: theme,
                notificationsStream: _watch('notifications'),
                lotsStream: _watch('lots'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final ProfileRepositoryImpl profileRepository;
  final ThemeProvider theme;

  const _DashboardHeader({
    required this.profileRepository,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: profileRepository.watchCurrentUserProfile(),
      builder: (context, profileSnapshot) {
        final name = _firstName(profileSnapshot.data);
        final message = name == null ? 'Bienvenue' : 'Bienvenue, $name';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
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
                color: const Color(0xFF5DB83D).withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.dashboard_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
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
                'Vue rapide du tableau de bord',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  static String? _firstName(UserProfile? profile) {
    final firstName = profile?.firstName.trim();
    if (firstName != null && firstName.isNotEmpty) return firstName;
    final fullName = profile?.fullName.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return null;
  }
}

class _QuickActions extends StatelessWidget {
  final ThemeProvider theme;

  const _QuickActions({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            theme: theme,
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            theme: theme,
            icon: Icons.warning_amber_rounded,
            label: 'Alertes',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AlertsScreen())),
          ),
        ),
      ],
    );
  }
}

class _OverviewPanel extends StatelessWidget {
  final ThemeProvider theme;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? buildingsStream;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? lotsStream;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? poultryTypesStream;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? notificationsStream;

  const _OverviewPanel({
    required this.theme,
    required this.buildingsStream,
    required this.lotsStream,
    required this.poultryTypesStream,
    required this.notificationsStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: buildingsStream,
      builder: (context, buildingsSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: lotsStream,
          builder: (context, lotsSnapshot) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: poultryTypesStream,
              builder: (context, typesSnapshot) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: notificationsStream,
                  builder: (context, notificationsSnapshot) {
                    final buildings = buildingsSnapshot.data?.docs ?? const [];
                    final lots = lotsSnapshot.data?.docs ?? const [];
                    final activeLots = lots
                        .where((doc) => doc.data()['isActive'] == true)
                        .toList();
                    final subjects = activeLots.fold<int>(
                      0,
                      (sum, doc) =>
                          sum +
                          ((doc.data()['currentBirdCount'] as num?) ?? 0)
                              .toInt(),
                    );
                    final occupiedBuildings = buildings
                        .where((doc) => doc.data()['status'] == 'active')
                        .length;
                    final unread = _unreadCount(notificationsSnapshot.data);

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 680;
                        final cards = [
                          _MetricTile(
                            title: 'Sujets',
                            value: subjects.toString(),
                            subtitle: 'effectif actif',
                            icon: Icons.egg_alt_rounded,
                            color: const Color(0xFF4B7B28),
                            theme: theme,
                          ),
                          _MetricTile(
                            title: 'Lots actifs',
                            value: activeLots.length.toString(),
                            subtitle: '${lots.length} au total',
                            icon: Icons.inventory_2_rounded,
                            color: const Color(0xFF5B8FA8),
                            theme: theme,
                          ),
                          _MetricTile(
                            title: 'Batiments',
                            value: '$occupiedBuildings/${buildings.length}',
                            subtitle: 'occupes',
                            icon: Icons.home_work_rounded,
                            color: const Color(0xFFB87333),
                            theme: theme,
                          ),
                          _MetricTile(
                            title: 'Types',
                            value: (typesSnapshot.data?.size ?? 0).toString(),
                            subtitle: unread == 0
                                ? 'aucune alerte'
                                : '$unread notification(s)',
                            icon: Icons.category_rounded,
                            color: unread == 0
                                ? const Color(0xFF6A9E40)
                                : const Color(0xFFAB1717),
                            theme: theme,
                          ),
                        ];

                        if (isWide) {
                          return Row(
                            children: [
                              for (var i = 0; i < cards.length; i++) ...[
                                Expanded(child: cards[i]),
                                if (i != cards.length - 1)
                                  const SizedBox(width: 10),
                              ],
                            ],
                          );
                        }

                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: cards,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  static int _unreadCount(QuerySnapshot<Map<String, dynamic>>? snapshot) {
    if (snapshot == null) return 0;
    return snapshot.docs.where((doc) {
      final data = doc.data();
      final status = data['status'] as String?;
      final isRelevant = status == 'scheduled' || status == 'received';
      return isRelevant && (data['isRead'] as bool? ?? false) == false;
    }).length;
  }
}

class _EnvironmentPanel extends StatelessWidget {
  final ThemeProvider theme;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? buildingsStream;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? devicesStream;

  const _EnvironmentPanel({
    required this.theme,
    required this.buildingsStream,
    required this.devicesStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: buildingsStream,
      builder: (context, buildingsSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: devicesStream,
          builder: (context, devicesSnapshot) {
            final buildings = buildingsSnapshot.data?.docs ?? const [];
            final devices = devicesSnapshot.data?.docs ?? const [];

            if (buildings.isEmpty) {
              return _EmptyPanel(
                theme: theme,
                icon: Icons.home_work_outlined,
                text: 'Aucun batiment configure pour le moment.',
              );
            }

            return Column(
              children: buildings.take(5).map((building) {
                final buildingData = building.data();
                final buildingDevices = devices
                    .where((doc) => doc.data()['buildingId'] == building.id)
                    .toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BuildingEnvironmentCard(
                    theme: theme,
                    buildingName: (buildingData['name'] ?? 'Batiment')
                        .toString(),
                    buildingStatus: (buildingData['status'] ?? 'empty')
                        .toString(),
                    tempMin: (buildingData['targetTempMin'] as num?)
                        ?.toDouble(),
                    tempMax: (buildingData['targetTempMax'] as num?)
                        ?.toDouble(),
                    humidityMin: (buildingData['targetHumidityMin'] as num?)
                        ?.toDouble(),
                    humidityMax: (buildingData['targetHumidityMax'] as num?)
                        ?.toDouble(),
                    devices: buildingDevices,
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class _BuildingEnvironmentCard extends StatelessWidget {
  final ThemeProvider theme;
  final String buildingName;
  final String buildingStatus;
  final double? tempMin;
  final double? tempMax;
  final double? humidityMin;
  final double? humidityMax;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> devices;

  const _BuildingEnvironmentCard({
    required this.theme,
    required this.buildingName,
    required this.buildingStatus,
    required this.tempMin,
    required this.tempMax,
    required this.humidityMin,
    required this.humidityMax,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: FutureBuilder<_EnvironmentReading?>(
        future: _latestReading(devices),
        builder: (context, snapshot) {
          final reading = snapshot.data;
          final tempState = _valueState(reading?.temperature, tempMin, tempMax);
          final humidityState = _valueState(
            reading?.humidity,
            humidityMin,
            humidityMax,
          );
          final statusColor = _statusColor(tempState, humidityState);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.sensors_rounded, color: statusColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buildingName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${_statusLabel(buildingStatus)} - ${devices.length} capteur(s)',
                          style: TextStyle(
                            color: theme.mutedColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(
                    label: reading == null
                        ? 'Sans lecture'
                        : _stateLabel(tempState, humidityState),
                    icon: reading == null
                        ? Icons.sync_problem_rounded
                        : Icons.check_circle_outline_rounded,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _LiveValue(
                      theme: theme,
                      icon: Icons.thermostat_rounded,
                      label: 'Temperature',
                      value: reading == null
                          ? '--'
                          : '${reading.temperature.toStringAsFixed(1)} C',
                      state: tempState,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LiveValue(
                      theme: theme,
                      icon: Icons.water_drop_rounded,
                      label: 'Humidite',
                      value: reading == null
                          ? '--'
                          : '${reading.humidity.toStringAsFixed(0)} %',
                      state: humidityState,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<_EnvironmentReading?> _latestReading(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> devices,
  ) async {
    _EnvironmentReading? latest;

    for (final device in devices) {
      final snapshot = await device.reference
          .collection('readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) continue;
      final doc = snapshot.docs.first;
      final data = doc.data();
      final timestamp =
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
      final reading = _EnvironmentReading(
        temperature: (data['temperature'] as num?)?.toDouble() ?? 0,
        humidity: (data['humidity'] as num?)?.toDouble() ?? 0,
        timestamp: timestamp,
      );
      if (latest == null || reading.timestamp.isAfter(latest.timestamp)) {
        latest = reading;
      }
    }

    return latest;
  }

  static _ReadingState _valueState(double? value, double? min, double? max) {
    if (value == null || min == null || max == null) return _ReadingState.none;
    if (value < min) return _ReadingState.low;
    if (value > max) return _ReadingState.high;
    return _ReadingState.ok;
  }

  static Color _statusColor(_ReadingState temp, _ReadingState humidity) {
    if (temp == _ReadingState.high || humidity == _ReadingState.high) {
      return const Color(0xFFAB1717);
    }
    if (temp == _ReadingState.low || humidity == _ReadingState.low) {
      return const Color(0xFFB87333);
    }
    if (temp == _ReadingState.none || humidity == _ReadingState.none) {
      return const Color(0xFF5B8FA8);
    }
    return const Color(0xFF4B7B28);
  }

  static String _stateLabel(_ReadingState temp, _ReadingState humidity) {
    if (temp == _ReadingState.ok && humidity == _ReadingState.ok) {
      return 'Normal';
    }
    if (temp == _ReadingState.none || humidity == _ReadingState.none) {
      return 'A verifier';
    }
    return 'Hors seuil';
  }

  static String _statusLabel(String value) {
    switch (value) {
      case 'active':
        return 'Actif';
      case 'disinfecting':
        return 'Desinfection';
      default:
        return 'Vide';
    }
  }
}

class _RiskPanel extends StatelessWidget {
  final ThemeProvider theme;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? lotsStream;

  const _RiskPanel({required this.theme, required this.lotsStream});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: lotsStream,
        builder: (context, snapshot) {
          final lots = snapshot.data?.docs ?? const [];
          final points = lots.map((doc) {
            final data = doc.data();
            final initial = (data['initialBirdCount'] as num?)?.toDouble() ?? 0;
            final current = (data['currentBirdCount'] as num?)?.toDouble() ?? 0;
            final safeInitial = initial <= 0 ? 1 : initial;
            final mortality =
                ((safeInitial - current).clamp(0, safeInitial) / safeInitial) *
                100;
            return _LotRisk(
              name: (data['identifier'] ?? 'Lot').toString(),
              building: (data['buildingName'] ?? '').toString(),
              mortality: mortality,
              isActive: data['isActive'] == true,
            );
          }).toList()..sort((a, b) => b.mortality.compareTo(a.mortality));

          final top = points.take(5).toList();
          if (top.isEmpty) {
            return Text(
              'Aucun lot disponible pour evaluer la mortalite.',
              style: TextStyle(color: theme.mutedColor),
            );
          }

          final values = top.map((e) => e.mortality).toList();
          return Column(
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(
                  painter: _BarChartPainter(
                    values: values,
                    color: const Color(0xFFAB1717),
                    mutedColor: theme.borderColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (final lot in top)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${lot.name}${lot.building.isEmpty ? '' : ' - ${lot.building}'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusPill(
                        label: '${lot.mortality.toStringAsFixed(1)} %',
                        icon: lot.isActive
                            ? Icons.trending_up_rounded
                            : Icons.lock_clock_rounded,
                        color: lot.mortality >= 5
                            ? const Color(0xFFAB1717)
                            : const Color(0xFF4B7B28),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _UpcomingVaccinationsPanel extends StatelessWidget {
  final ThemeProvider theme;
  final Stream<List<Map<String, dynamic>>> stream;

  const _UpcomingVaccinationsPanel({required this.theme, required this.stream});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return Text(
              'Aucun rappel de vaccination planifie.',
              style: TextStyle(color: theme.mutedColor),
            );
          }

          return Column(
            children: items.map((item) {
              final title = (item['title'] ?? 'Vaccination').toString();
              final message = (item['message'] ?? '').toString();
              final date = (item['scheduledAt'] as Timestamp?)?.toDate();
              final dateLabel = date == null
                  ? '--'
                  : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B7B28).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.vaccines_rounded,
                        color: Color(0xFF4B7B28),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (message.isNotEmpty)
                            Text(
                              message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.mutedColor,
                                fontSize: 12,
                                height: 1.25,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: theme.textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _RightSummaryPanel extends StatelessWidget {
  final ThemeProvider theme;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? notificationsStream;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? lotsStream;

  const _RightSummaryPanel({
    required this.theme,
    required this.notificationsStream,
    required this.lotsStream,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          theme: theme,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vue rapide',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _CompactStat(
                      label: 'Alertes',
                      value: 'Live',
                      color: const Color(0xFFAB1717),
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CompactStat(
                      label: 'Suivi',
                      value: '24/7',
                      color: const Color(0xFF5B8FA8),
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    values: const [2, 4, 6, 3, 7, 5, 6],
                    color: theme.mutedColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          theme: theme,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dernieres alertes',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: notificationsStream,
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return Text(
                      'Aucune alerte recente',
                      style: TextStyle(color: theme.mutedColor),
                    );
                  }
                  return Column(
                    children: docs.take(3).map((d) {
                      final data = d.data();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFAB1717),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (data['title'] ?? 'Alerte').toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: theme.textColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          theme: theme,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lots critiques',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: lotsStream,
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? const [];
                  final risks =
                      docs.map((d) {
                        final data = d.data();
                        final initial =
                            (data['initialBirdCount'] as num?)?.toDouble() ?? 1;
                        final current =
                            (data['currentBirdCount'] as num?)?.toDouble() ?? 0;
                        final mortality =
                            ((initial - current) /
                                (initial <= 0 ? 1 : initial)) *
                            100;
                        return {
                          'mort': mortality,
                          'name': (data['identifier'] ?? 'Lot').toString(),
                        };
                      }).toList()..sort(
                        (a, b) => (b['mort'] as double).compareTo(
                          a['mort'] as double,
                        ),
                      );

                  if (risks.isEmpty) {
                    return Text(
                      'Aucun lot critique',
                      style: TextStyle(color: theme.mutedColor),
                    );
                  }

                  return Column(
                    children: risks.take(3).map((r) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                r['name'].toString(),
                                style: TextStyle(color: theme.textColor),
                              ),
                            ),
                            Text(
                              '${(r['mort'] as double).toStringAsFixed(1)} %',
                              style: const TextStyle(
                                color: Color(0xFFAB1717),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final ThemeProvider theme;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      theme: theme,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.mutedColor, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _LiveValue extends StatelessWidget {
  final ThemeProvider theme;
  final IconData icon;
  final String label;
  final String value;
  final _ReadingState state;

  const _LiveValue({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _ReadingState.ok => const Color(0xFF4B7B28),
      _ReadingState.low => const Color(0xFFB87333),
      _ReadingState.high => const Color(0xFFAB1717),
      _ReadingState.none => const Color(0xFF5B8FA8),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.mutedColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final ThemeProvider theme;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: FilledButton.styleFrom(
        backgroundColor: theme.headerColor,
        foregroundColor: theme.textColor,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String actionLabel;
  final ThemeProvider theme;

  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          actionLabel,
          style: TextStyle(
            color: theme.mutedColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final ThemeProvider theme;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _Panel({
    required this.theme,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.borderColor),
      ),
      child: child,
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final ThemeProvider theme;
  final IconData icon;
  final String text;

  const _EmptyPanel({
    required this.theme,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      theme: theme,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: theme.mutedColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: theme.mutedColor)),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  final ThemeProvider theme;
  final String label;
  final String value;
  final Color color;

  const _CompactStat({
    required this.theme,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: theme.mutedColor, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final paint = Paint()
      ..color = color.withOpacity(0.9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    final maxValue = values.reduce(math.max);
    for (var i = 0; i < values.length; i++) {
      final x = i * (size.width / (values.length - 1));
      final y =
          size.height -
          (values[i] / (maxValue == 0 ? 1 : maxValue)) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color mutedColor;

  const _BarChartPainter({
    required this.values,
    required this.color,
    required this.mutedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final gridPaint = Paint()
      ..color = mutedColor
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = math.max(values.reduce(math.max), 1);
    final gap = 10.0;
    final barWidth = (size.width - gap * (values.length - 1)) / values.length;
    final paint = Paint()..color = color;

    for (var i = 0; i < values.length; i++) {
      final height = (values[i] / maxValue).clamp(0.0, 1.0) * size.height;
      final left = i * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        const Radius.circular(5),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.mutedColor != mutedColor;
  }
}

class _EnvironmentReading {
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  const _EnvironmentReading({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });
}

class _LotRisk {
  final String name;
  final String building;
  final double mortality;
  final bool isActive;

  const _LotRisk({
    required this.name,
    required this.building,
    required this.mortality,
    required this.isActive,
  });
}

enum _ReadingState { ok, low, high, none }
