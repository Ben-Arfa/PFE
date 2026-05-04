import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kiwo/core/theme_provider.dart';
import 'package:kiwo/features/farm_management/domain/entities/farm_management_models.dart'
    as farm;
import 'package:kiwo/features/farm_management/domain/usecases/farm_management_usecases.dart';
import 'package:kiwo/features/gestions_des_batiments/data/repositories/building_repository_impl.dart';
import 'package:kiwo/features/gestions_des_batiments/data/services/building_service.dart';
import 'package:kiwo/features/gestions_des_batiments/domain/entities/building.dart'
    as farm_building;
import 'package:kiwo/features/gestions_des_lots_des_volailles/domain/entities/flock_lot.dart'
    as lot_entity;
import 'package:kiwo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kiwo/features/profile/data/services/profile_service.dart';
import 'package:kiwo/features/profile/domain/entities/user_profile.dart';
import 'package:kiwo/features/suivi_des_vaccinations/data/repositories/vaccination_repository_impl.dart';
import 'package:kiwo/features/suivi_des_vaccinations/data/services/vaccination_service.dart';
import 'package:kiwo/features/suivi_des_vaccinations/domain/entities/vaccination_plan.dart';
import 'package:kiwo/features/suivi_des_vaccinations/domain/repositories/vaccination_repository.dart';
import 'package:kiwo/shared/presentation/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final FarmManagementUseCases _farmUseCases = FarmManagementUseCases();
  late final BuildingRepositoryImpl _buildingRepository =
      BuildingRepositoryImpl(BuildingService());
  late final VaccinationRepository _vaccinationRepository =
      VaccinationRepositoryImpl(VaccinationService());
  late final ProfileRepositoryImpl _profileRepository = ProfileRepositoryImpl(
    ProfileService(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeHeader(profileRepository: _profileRepository, theme: theme),
            const SizedBox(height: 22),
            _SectionHeader(
              title: 'Bilan général',
              subtitle: 'Bâtiments, lots et types présents',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _BalanceOverview(
              buildingRepository: _buildingRepository,
              farmUseCases: _farmUseCases,
              theme: theme,
            ),
            const SizedBox(height: 22),
            _SectionHeader(
              title: 'Taux de mortalité par lot',
              subtitle: 'Une courbe par lot actif',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _MortalityOverview(farmUseCases: _farmUseCases, theme: theme),
            const SizedBox(height: 22),
            _SectionHeader(
              title: 'État de l\'environnement',
              subtitle: 'Paramètres et état de chaque bâtiment',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _EnvironmentOverview(
              buildingRepository: _buildingRepository,
              farmUseCases: _farmUseCases,
              theme: theme,
            ),
            const SizedBox(height: 22),
            _SectionHeader(
              title: 'Vaccinations à venir',
              subtitle: 'Les prochaines vaccinations par lot',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _VaccinationOverview(
              repository: _vaccinationRepository,
              theme: theme,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final ProfileRepositoryImpl profileRepository;
  final ThemeProvider theme;

  const _WelcomeHeader({required this.profileRepository, required this.theme});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: profileRepository.watchCurrentUserProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final firstName = _resolveFirstName(profile);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue${firstName == null ? '' : ', $firstName'} 👋',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tout l\'essentiel en un coup d\'œil.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.textColor.withValues(alpha: 0.78),
                height: 1.25,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  String? _resolveFirstName(UserProfile? profile) {
    final name = profile?.firstName.trim();
    if (name != null && name.isNotEmpty) return name;
    final fullName = profile?.fullName.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return null;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final ThemeProvider theme;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: theme.mutedColor,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _BalanceOverview extends StatelessWidget {
  final BuildingRepositoryImpl buildingRepository;
  final FarmManagementUseCases farmUseCases;
  final ThemeProvider theme;

  const _BalanceOverview({
    required this.buildingRepository,
    required this.farmUseCases,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<farm.FlockLot>>(
      stream: farmUseCases.watchLots(status: LotStatus.active),
      builder: (context, lotsSnapshot) {
        return StreamBuilder<List<farm.Building>>(
          stream: farmUseCases.watchBuildings(),
          builder: (context, buildingsSnapshot) {
            return StreamBuilder<List<farm.PoultryType>>(
              stream: farmUseCases.watchPoultryTypes(),
              builder: (context, typesSnapshot) {
                final buildings =
                    buildingsSnapshot.data ?? const <farm.Building>[];
                final lots = lotsSnapshot.data ?? const <farm.FlockLot>[];
                final types = typesSnapshot.data ?? const <farm.PoultryType>[];

                final typesPresent = types.length;
                final activeLots = lots.length;

                if ((buildingsSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !buildingsSnapshot.hasData) ||
                    (lotsSnapshot.connectionState == ConnectionState.waiting &&
                        !lotsSnapshot.hasData) ||
                    (typesSnapshot.connectionState == ConnectionState.waiting &&
                        !typesSnapshot.hasData)) {
                  return const _LoadingCard();
                }

                return Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.domain_rounded,
                        label: 'Bâtiments',
                        value: '${buildings.length}',
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.groups_rounded,
                        label: 'Lots actifs',
                        value: '$activeLots',
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.category_rounded,
                        label: 'Types',
                        value: '$typesPresent',
                        theme: theme,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MortalityOverview extends StatelessWidget {
  final FarmManagementUseCases farmUseCases;
  final ThemeProvider theme;

  const _MortalityOverview({required this.farmUseCases, required this.theme});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<farm.FlockLot>>(
      stream: farmUseCases.watchLots(status: LotStatus.active),
      builder: (context, lotsSnapshot) {
        final lots = lotsSnapshot.data ?? const <farm.FlockLot>[];

        if (lotsSnapshot.connectionState == ConnectionState.waiting &&
            !lotsSnapshot.hasData) {
          return const _LoadingCard();
        }

        if (lots.isEmpty) {
          return const _CompactInfoCard(
            child: Center(child: Text('Aucun lot actif.')),
          );
        }

        return _CompactInfoCard(
          child: Column(
            children: [
              for (
                var index = 0;
                index < math.min(lots.length, 3);
                index++
              ) ...[
                _MortalityRow(
                  lot: lots[index],
                  farmUseCases: farmUseCases,
                  theme: theme,
                  colorIndex: index,
                ),
                if (index < math.min(lots.length, 3) - 1)
                  const SizedBox(height: 8),
              ],
              if (lots.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '+${lots.length - 3} autres lots actifs',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.mutedColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MortalityRow extends StatelessWidget {
  final farm.FlockLot lot;
  final FarmManagementUseCases farmUseCases;
  final ThemeProvider theme;
  final int colorIndex;

  const _MortalityRow({
    required this.lot,
    required this.farmUseCases,
    required this.theme,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final palette = [
      AppColors.green,
      const Color(0xFF2D6CDF),
      const Color(0xFFE08A00),
      const Color(0xFF7A5CFA),
    ];
    final accentColor = palette[colorIndex % palette.length];

    return StreamBuilder<List<farm.DailyEntry>>(
      stream: farmUseCases.watchDailyEntries(lot.id),
      builder: (context, entriesSnapshot) {
        final entries = entriesSnapshot.data ?? const <farm.DailyEntry>[];
        final currentRate = _currentMortalityRate(lot, entries);
        final points = _buildMortalityRates(lot, entries);

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.headerColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.mutedColor.withValues(alpha: 0.08)),
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
                        Text(
                          lot.identifier,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: theme.textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lot.poultryTypeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    label: '${currentRate.toStringAsFixed(1)}%',
                    backgroundColor: accentColor.withValues(alpha: 0.12),
                    foregroundColor: accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: points.isEmpty
                    ? Center(
                        child: Text(
                          'Pas de données',
                          style: TextStyle(color: theme.mutedColor),
                        ),
                      )
                    : CustomPaint(
                        painter: _LineChartPainter(
                          values: points,
                          lineColor: accentColor,
                        ),
                        child: Container(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _currentMortalityRate(
    farm.FlockLot lot,
    List<farm.DailyEntry> entries,
  ) {
    if (entries.isEmpty || lot.initialBirdCount <= 0) return 0;

    final sorted = [...entries]
      ..sort((left, right) => left.entryDate.compareTo(right.entryDate));
    var cumulativeDeaths = 0;
    for (final entry in sorted) {
      cumulativeDeaths += entry.dailyMortality;
    }

    return (cumulativeDeaths / lot.initialBirdCount) * 100;
  }

  List<double> _buildMortalityRates(
    farm.FlockLot lot,
    List<farm.DailyEntry> entries,
  ) {
    if (entries.isEmpty || lot.initialBirdCount <= 0) return const [];

    final sorted = [...entries]
      ..sort((left, right) => left.entryDate.compareTo(right.entryDate));
    var cumulativeDeaths = 0;
    final rates = <double>[];
    for (final entry in sorted) {
      cumulativeDeaths += entry.dailyMortality;
      final rate = (cumulativeDeaths / lot.initialBirdCount) * 100;
      rates.add(rate);
    }

    return rates;
  }
}

class _EnvironmentOverview extends StatelessWidget {
  final BuildingRepositoryImpl buildingRepository;
  final FarmManagementUseCases farmUseCases;
  final ThemeProvider theme;

  const _EnvironmentOverview({
    required this.buildingRepository,
    required this.farmUseCases,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<farm_building.Building>>(
      stream: buildingRepository.watchBuildings(),
      builder: (context, buildingsSnapshot) {
        final buildings =
            buildingsSnapshot.data ?? const <farm_building.Building>[];

        return StreamBuilder<List<farm.FlockLot>>(
          stream: farmUseCases.watchLots(status: LotStatus.active),
          builder: (context, lotsSnapshot) {
            final activeLots = lotsSnapshot.data ?? const <farm.FlockLot>[];
            final lotsByBuildingId = {
              for (final lot in activeLots) lot.buildingId: lot,
            };

            if (buildingsSnapshot.connectionState == ConnectionState.waiting &&
                !buildingsSnapshot.hasData &&
                lotsSnapshot.connectionState == ConnectionState.waiting &&
                !lotsSnapshot.hasData) {
              return const _LoadingCard();
            }

            if (buildings.isEmpty) {
              return const _CompactInfoCard(
                child: Center(child: Text('Aucun bâtiment enregistré.')),
              );
            }

            return _CompactInfoCard(
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < math.min(buildings.length, 3);
                    index++
                  ) ...[
                    _EnvironmentRow(
                      building: buildings[index],
                      activeLot: lotsByBuildingId[buildings[index].id],
                      theme: theme,
                    ),
                    if (index < math.min(buildings.length, 3) - 1)
                      const SizedBox(height: 8),
                  ],
                  if (buildings.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+${buildings.length - 3} autres bâtiments',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.mutedColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EnvironmentRow extends StatelessWidget {
  final farm_building.Building building;
  final farm.FlockLot? activeLot;
  final ThemeProvider theme;

  const _EnvironmentRow({
    required this.building,
    required this.activeLot,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (building.status) {
      farm_building.BuildingStatus.active => AppColors.green,
      farm_building.BuildingStatus.empty => const Color(0xFF7A7A7A),
      farm_building.BuildingStatus.disinfecting => const Color(0xFFE08A00),
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.headerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.mutedColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  building.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activeLot == null
                      ? 'Aucun lot actif'
                      : 'Lot ${activeLot!.identifier}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: theme.mutedColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(
            label: building.status.label,
            backgroundColor: statusColor.withValues(alpha: 0.12),
            foregroundColor: statusColor,
          ),
        ],
      ),
    );
  }
}

class _VaccinationOverview extends StatelessWidget {
  final VaccinationRepository repository;
  final ThemeProvider theme;

  const _VaccinationOverview({required this.repository, required this.theme});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<lot_entity.FlockLot>>(
      stream: repository.watchActiveLots(),
      builder: (context, lotsSnapshot) {
        final lots = lotsSnapshot.data ?? const <lot_entity.FlockLot>[];

        if (lotsSnapshot.connectionState == ConnectionState.waiting &&
            !lotsSnapshot.hasData) {
          return const _LoadingCard();
        }

        if (lots.isEmpty) {
          return const _CompactInfoCard(
            child: Center(child: Text('Aucun lot actif.')),
          );
        }

        return _CompactInfoCard(
          child: Column(
            children: [
              for (
                var index = 0;
                index < math.min(lots.length, 3);
                index++
              ) ...[
                _VaccinationLotRow(
                  repository: repository,
                  lot: lots[index],
                  theme: theme,
                  colorIndex: index,
                ),
                if (index < math.min(lots.length, 3) - 1)
                  const SizedBox(height: 8),
              ],
              if (lots.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '+${lots.length - 3} autres lots actifs',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.mutedColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _VaccinationLotRow extends StatelessWidget {
  final VaccinationRepository repository;
  final lot_entity.FlockLot lot;
  final ThemeProvider theme;
  final int colorIndex;

  const _VaccinationLotRow({
    required this.repository,
    required this.lot,
    required this.theme,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final palette = [
      AppColors.green,
      const Color(0xFF2D6CDF),
      const Color(0xFFE08A00),
      const Color(0xFF7A5CFA),
    ];
    final accentColor = palette[colorIndex % palette.length];

    return StreamBuilder<List<VaccinationPlan>>(
      stream: repository.watchPlans(lot.id),
      builder: (context, plansSnapshot) {
        final plans = plansSnapshot.data ?? const <VaccinationPlan>[];
        final pendingPlans = plans.where((plan) => !plan.isCompleted).toList()
          ..sort(
            (left, right) => left.plannedDate.compareTo(right.plannedDate),
          );
        final nextPlan = pendingPlans.isEmpty ? null : pendingPlans.first;

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.headerColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.mutedColor.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lot.identifier,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: theme.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextPlan == null
                          ? 'Aucune vaccination planifiée'
                          : '${nextPlan.vaccineName} · ${_formatDate(nextPlan.plannedDate.toDate())}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: theme.mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: '${pendingPlans.length}',
                backgroundColor: accentColor.withValues(alpha: 0.12),
                foregroundColor: accentColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeProvider theme;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.green, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, color: theme.mutedColor),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _StatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class _CompactInfoCard extends StatelessWidget {
  final Widget child;

  const _CompactInfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(10), child: child),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.green,
            backgroundColor: theme.mutedColor.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month';
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  _LineChartPainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final range = (maxV - minV) > 0 ? (maxV - minV) : 1.0;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final normalized = (values[i] - minV) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // draw shadow/area under curve
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = lineColor.withOpacity(0.12)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}
