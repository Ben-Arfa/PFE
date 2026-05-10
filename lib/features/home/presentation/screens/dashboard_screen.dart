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

  CollectionReference<Map<String, dynamic>>? _notificationsCollection() {
    return _userCollection('notifications');
  }

  CollectionReference<Map<String, dynamic>>? _buildingsCollection() {
    return _userCollection('buildings');
  }

  CollectionReference<Map<String, dynamic>>? _lotsCollection() {
    return _userCollection('lots');
  }

  CollectionReference<Map<String, dynamic>>? _poultryTypesCollection() {
    return _userCollection('poultryTypes');
  }

  Stream<int> _watchCollectionCount(
    CollectionReference<Map<String, dynamic>>? collection,
  ) {
    if (collection == null) return const Stream<int>.empty();
    return collection.snapshots().map((snapshot) => snapshot.size);
  }

  Stream<int> _watchUnreadNotificationsCount() {
    final collection = _notificationsCollection();
    if (collection == null) return const Stream<int>.empty();

    return collection.snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final status = data['status'] as String?;
        final isRelevant = status == 'scheduled' || status == 'received';
        final isRead = data['isRead'] as bool? ?? false;
        return isRelevant && !isRead;
      }).length;
    });
  }

  Stream<List<Map<String, dynamic>>> _watchLotsForMortality() {
    final collection = _lotsCollection();
    if (collection == null) {
      return const Stream<List<Map<String, dynamic>>>.empty();
    }
    return collection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  Stream<List<Map<String, dynamic>>> _watchUpcomingVaccinations() {
    final collection = _notificationsCollection();
    if (collection == null) {
      return const Stream<List<Map<String, dynamic>>>.empty();
    }

    return collection
        .orderBy('scheduledAt', descending: false)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final items = snapshot.docs
              .map((doc) => doc.data())
              .where((data) {
                final status = data['status'] as String?;
                final isVaccinationReminder =
                    status == 'scheduled' || status == 'received';
                if (!isVaccinationReminder) return false;
                final planned = (data['scheduledAt'] as Timestamp?)?.toDate();
                if (planned == null) return false;
                return planned.isAfter(now) || _isSameDay(planned, now);
              })
              .take(5)
              .toList();
          return items;
        });
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardHero(profileRepository: _profileRepository, theme: theme),
            const SizedBox(height: 20),
            _TopActionButtons(
              theme: theme,
              unreadStream: _watchUnreadNotificationsCount(),
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              title: 'Bilan general',
              subtitle: 'Vue rapide des ressources principales.',
              theme: theme,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 700) {
                  return Row(
                    children: [
                      Expanded(
                        child: _DashboardMetricCard(
                          title: 'Batiments',
                          subtitle: 'espaces configurés',
                          icon: Icons.home_work_rounded,
                          accentColor: const Color(0xFF5DB83D),
                          stream: _watchCollectionCount(_buildingsCollection()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DashboardMetricCard(
                          title: 'Lots',
                          subtitle: 'lots enregistres',
                          icon: Icons.groups_2_rounded,
                          accentColor: const Color(0xFF1E88E5),
                          stream: _watchCollectionCount(_lotsCollection()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DashboardMetricCard(
                          title: 'Types',
                          subtitle: 'types volailles',
                          icon: Icons.category_rounded,
                          accentColor: const Color(0xFF8A5A2B),
                          stream: _watchCollectionCount(
                            _poultryTypesCollection(),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final cardWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _DashboardMetricCard(
                        title: 'Batiments',
                        subtitle: 'espaces configurés',
                        icon: Icons.home_work_rounded,
                        accentColor: const Color(0xFF5DB83D),
                        stream: _watchCollectionCount(_buildingsCollection()),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _DashboardMetricCard(
                        title: 'Lots',
                        subtitle: 'lots enregistres',
                        icon: Icons.groups_2_rounded,
                        accentColor: const Color(0xFF1E88E5),
                        stream: _watchCollectionCount(_lotsCollection()),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _DashboardMetricCard(
                        title: 'Types',
                        subtitle: 'types volailles',
                        icon: Icons.category_rounded,
                        accentColor: const Color(0xFF8A5A2B),
                        stream: _watchCollectionCount(
                          _poultryTypesCollection(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              title: 'Etat de l\'environnement des batiments',
              subtitle: 'Bloc de monitoring detaille a venir.',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _EnvironmentPreviewCard(
              theme: theme,
              buildingsStream: _buildingsCollection()?.snapshots(),
            ),
            const SizedBox(height: 12),
            _SectionTitle(
              title: 'Courbe de mortalite par lot',
              subtitle: 'Estimation basee sur effectif initial et actuel.',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _MortalityCurveCard(
              theme: theme,
              lotsStream: _watchLotsForMortality(),
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              title: 'Vaccinations a venir',
              subtitle: 'Prochains rappels planifies.',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _UpcomingVaccinationsCard(
              theme: theme,
              stream: _watchUpcomingVaccinations(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  final ProfileRepositoryImpl profileRepository;
  final ThemeProvider theme;

  const _DashboardHero({required this.profileRepository, required this.theme});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: profileRepository.watchCurrentUserProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final firstName = _resolveFirstName(profile);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5DB83D), Color(0xFF8FD14E)],
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
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Text('🐔', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName == null
                          ? 'Tableau de bord'
                          : 'Tableau de bord, $firstName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Vue globale elevage, mortalite et vaccination.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final ThemeProvider theme;

  const _SectionTitle({
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
            color: theme.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: theme.textColor.withValues(alpha: 0.72),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Stream<int> stream;

  const _DashboardMetricCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(height: 18),
              Text(
                value.toString(),
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: theme.mutedColor,
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopActionButtons extends StatelessWidget {
  final ThemeProvider theme;
  final Stream<int> unreadStream;

  const _TopActionButtons({required this.theme, required this.unreadStream});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<int>(
            stream: unreadStream,
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.headerColor,
                  foregroundColor: theme.textColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_outlined),
                        if (unreadCount > 0)
                          Positioned(
                            right: -8,
                            top: -8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                unreadCount > 99
                                    ? '99+'
                                    : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Text('Notifications'),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AlertsScreen())),
            icon: const Icon(Icons.warning_amber_outlined),
            label: const Text('Alertes'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.headerColor,
              foregroundColor: theme.textColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EnvironmentPreviewCard extends StatelessWidget {
  final ThemeProvider theme;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? buildingsStream;

  const _EnvironmentPreviewCard({
    required this.theme,
    required this.buildingsStream,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderColor),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: buildingsStream,
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return Text(
              'Aucun batiment configure pour le moment. Module environnement a venir.',
              style: TextStyle(color: theme.mutedColor, height: 1.35),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.eco_rounded, color: theme.textColor),
                  const SizedBox(width: 8),
                  Text(
                    'Chaque batiment sera relie aux capteurs IoT bientot',
                    style: TextStyle(
                      color: theme.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: docs.take(6).map((doc) {
                  final name = (doc.data()['name'] ?? 'Batiment').toString();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5DB83D).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$name  -  etat a venir',
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MortalityPoint {
  final String lotIdentifier;
  final double mortalityPct;

  const _MortalityPoint({
    required this.lotIdentifier,
    required this.mortalityPct,
  });
}

class _MortalityCurveCard extends StatelessWidget {
  final ThemeProvider theme;
  final Stream<List<Map<String, dynamic>>> lotsStream;

  const _MortalityCurveCard({required this.theme, required this.lotsStream});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderColor),
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: lotsStream,
        builder: (context, snapshot) {
          final raw = snapshot.data ?? const [];
          final points = raw.map((lot) {
            final identifier = (lot['identifier'] ?? 'Lot').toString();
            final initial = (lot['initialBirdCount'] as num?)?.toDouble() ?? 0;
            final current = (lot['currentBirdCount'] as num?)?.toDouble() ?? 0;
            final safeInitial = initial <= 0 ? 1 : initial;
            final mortality =
                ((safeInitial - current).clamp(0, safeInitial) / safeInitial) *
                100;
            return _MortalityPoint(
              lotIdentifier: identifier,
              mortalityPct: mortality,
            );
          }).toList()..sort((a, b) => b.mortalityPct.compareTo(a.mortalityPct));

          final top = points.take(6).toList();
          if (top.isEmpty) {
            return Text(
              'Pas encore de donnees de lots pour construire la courbe.',
              style: TextStyle(color: theme.mutedColor),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: CustomPaint(
                  painter: _MortalityLinePainter(
                    values: top.map((e) => e.mortalityPct).toList(),
                    lineColor: const Color(0xFFE53935),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (final point in top)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          point.lotIdentifier,
                          style: TextStyle(
                            color: theme.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${point.mortalityPct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: const Color(0xFFE53935),
                          fontWeight: FontWeight.w700,
                        ),
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

class _MortalityLinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  const _MortalityLinePainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (values.isEmpty) return;
    final maxValue = values.reduce(math.max).clamp(1, 100).toDouble();
    final stepX = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = stepX * i;
      final normalized = (values[i] / maxValue).clamp(0, 1);
      final y = size.height - (normalized * (size.height - 8)) - 4;
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(areaPath, basePaint);
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (final point in points) {
      canvas.drawCircle(point, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MortalityLinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}

class _UpcomingVaccinationsCard extends StatelessWidget {
  final ThemeProvider theme;
  final Stream<List<Map<String, dynamic>>> stream;

  const _UpcomingVaccinationsCard({required this.theme, required this.stream});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderColor),
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return Text(
              'Aucune vaccination planifiee pour les prochains jours.',
              style: TextStyle(color: theme.mutedColor),
            );
          }

          return Column(
            children: items.map((item) {
              final title = (item['title'] ?? 'Vaccination').toString();
              final message = (item['message'] ?? '').toString();
              final date = (item['scheduledAt'] as Timestamp?)?.toDate();
              final dateLabel = date == null
                  ? '-'
                  : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5DB83D).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.vaccines_rounded,
                      color: Color(0xFF5DB83D),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: theme.textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (message.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              message,
                              style: TextStyle(
                                color: theme.mutedColor,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
