import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class VaccinationNotificationService {
  VaccinationNotificationService._();

  static final instance = VaccinationNotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Timer? _pollingTimer;
  Map<String, Timer> _scheduledTimers = {}; // Garde les timers individuels
  bool _initialized = false;

  CollectionReference<Map<String, dynamic>> _notifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  String _docIdForPlan(String planId) => 'vaccination_plan_$planId';

  int _notificationIdForPlan(String planId) {
    return planId.hashCode & 0x7fffffff;
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    developer.log('Initializing VaccinationNotificationService');

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initializationSettings);

    // Créer le canal Android pour les rappels
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      developer.log('Creating Android notification channel');
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'vaccination_reminders',
          'Rappels de vaccination',
          description:
              'Notifications de rappel pour les vaccinations planifiees.',
          importance: Importance.max,
          enableVibration: true,
        ),
      );

      // Demander la permission POST_NOTIFICATIONS
      developer.log('Requesting POST_NOTIFICATIONS permission');
      await androidPlugin.requestNotificationsPermission();
    }

    // Demander les permissions iOS
    final iosPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosPlugin != null) {
      developer.log('Requesting iOS notification permissions');
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }

    // Polling toutes les 30 secondes pour vérifier les rappels
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      developer.log('Processing due reminders');
      processDueReminders();
    });

    developer.log('VaccinationNotificationService initialized');
    await processDueReminders();
  }

  Future<void> schedulePlanReminders({
    required String planId,
    required String lotIdentifier,
    required String vaccineName,
    required String administrationRoute,
    required DateTime plannedDate,
    required double dosePerSubject,
  }) async {
    await init();

    final now = DateTime.now();
    final isDue =
        plannedDate.isBefore(now) || plannedDate.isAtSameMomentAs(now);
    final notificationId = _notificationIdForPlan(planId);

    developer.log(
      'Scheduling reminder for plan $planId at $plannedDate (isDue: $isDue)',
    );

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'vaccination_reminders',
        'Rappels de vaccination',
        channelDescription:
            'Notifications de rappel pour les vaccinations planifiees.',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final title = 'Rappel vaccination';
    final body =
        'Lot $lotIdentifier: $vaccineName ($administrationRoute) - dose $dosePerSubject';

    // Afficher immédiatement si c'est déjà l'heure
    if (isDue) {
      developer.log('Showing immediate notification for plan $planId');
      await _localNotifications.show(notificationId, title, body, details);
    } else {
      // Planifier avec un Timer local au lieu de zonedSchedule
      final delayDuration = plannedDate.difference(now);
      developer.log(
        'Scheduling notification in ${delayDuration.inSeconds} seconds',
      );

      // Annuler le timer précédent s'il existe
      _scheduledTimers[planId]?.cancel();

      // Créer un nouveau timer
      _scheduledTimers[planId] = Timer(delayDuration, () async {
        developer.log('Timer fired for plan $planId, showing notification');
        await _localNotifications.show(notificationId, title, body, details);
        _scheduledTimers.remove(planId);
      });
    }

    // Enregistrer dans Firestore
    await _notifications().doc(_docIdForPlan(planId)).set({
      'type': 'vaccination_reminder',
      'sourceId': planId,
      'title': title,
      'message': body,
      'scheduledAt': Timestamp.fromDate(plannedDate),
      'notificationId': notificationId,
      'status': isDue ? 'received' : 'scheduled',
      'receivedAt': isDue ? Timestamp.fromDate(now) : null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> cancelPlanReminders(String planId) async {
    await init();

    developer.log('Cancelling reminders for plan $planId');

    await _localNotifications.cancel(_notificationIdForPlan(planId));

    // Annuler le timer s'il existe
    _scheduledTimers[planId]?.cancel();
    _scheduledTimers.remove(planId);

    await _notifications().doc(_docIdForPlan(planId)).set({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> processDueReminders() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final now = Timestamp.fromDate(DateTime.now());
      final dueSnapshot = await _notifications()
          .where('type', isEqualTo: 'vaccination_reminder')
          .where('status', isEqualTo: 'scheduled')
          .where('scheduledAt', isLessThanOrEqualTo: now)
          .get();

      developer.log('Found ${dueSnapshot.docs.length} due reminders');

      for (final doc in dueSnapshot.docs) {
        developer.log('Marking reminder as received: ${doc.id}');
        await doc.reference.set({
          'status': 'received',
          'receivedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      developer.log('Error processing due reminders: $e');
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    for (final timer in _scheduledTimers.values) {
      timer.cancel();
    }
    _scheduledTimers.clear();
  }
}
