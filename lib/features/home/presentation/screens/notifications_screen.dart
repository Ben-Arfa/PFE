import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiwo/core/theme_provider.dart';

import '../../../suivi_des_vaccinations/data/services/vaccination_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final theme = ThemeProvider.instance;

  CollectionReference<Map<String, dynamic>>? _notificationsCollection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications');
  }

  @override
  void initState() {
    super.initState();
    VaccinationNotificationService.instance.processDueReminders();
  }

  @override
  Widget build(BuildContext context) {
    final collection = _notificationsCollection();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: theme.headerColor,
        foregroundColor: theme.textColor,
      ),
      body: collection == null
          ? Center(
              child: Text(
                'Connectez-vous pour voir vos notifications.',
                style: TextStyle(color: theme.mutedColor),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: collection
                  .orderBy('scheduledAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur de chargement des notifications.',
                      style: TextStyle(color: theme.mutedColor),
                    ),
                  );
                }

                final docs = (snapshot.data?.docs ?? const []).where((doc) {
                  final status = doc.data()['status'] as String?;
                  return status == 'scheduled' || status == 'received';
                }).toList();
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Aucune notification pour le moment.',
                        style: TextStyle(color: theme.mutedColor, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final title = data['title'] as String? ?? 'Notification';
                    final message = data['message'] as String? ?? '';
                    final status = data['status'] as String? ?? 'scheduled';
                    final scheduledAt = (data['scheduledAt'] as Timestamp?)
                        ?.toDate();

                    final dateText = scheduledAt == null
                        ? '-'
                        : '${scheduledAt.day.toString().padLeft(2, '0')}/${scheduledAt.month.toString().padLeft(2, '0')}/${scheduledAt.year} ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          status == 'received'
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          color: status == 'received'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        title: Text(title),
                        subtitle: Text('$message\n$dateText'),
                        isThreeLine: true,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'received'
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status == 'received' ? 'Reçue' : 'Planifiée',
                            style: TextStyle(
                              color: status == 'received'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
