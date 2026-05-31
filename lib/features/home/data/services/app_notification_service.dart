import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppNotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AppNotificationService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _notifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  Future<void> createReceived({
    required String title,
    required String message,
    String type = 'iot_action',
    Map<String, dynamic> metadata = const {},
  }) async {
    final now = Timestamp.now();
    await _notifications().add({
      'title': title,
      'message': message,
      'type': type,
      'scheduledAt': now,
      'receivedAt': now,
      'createdAt': now,
      'updatedAt': now,
      'status': 'received',
      'isRead': false,
      'metadata': metadata,
    });
  }
}
