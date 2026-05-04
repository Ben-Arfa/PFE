import 'package:cloud_firestore/cloud_firestore.dart';

class LotHistoryEvent {
  final String id;
  final String lotId;
  final String type;
  final String title;
  final String description;
  final Timestamp eventAt;
  final Timestamp createdAt;
  final Map<String, dynamic>? metadata;

  const LotHistoryEvent({
    required this.id,
    required this.lotId,
    required this.type,
    required this.title,
    required this.description,
    required this.eventAt,
    required this.createdAt,
    this.metadata,
  });

  factory LotHistoryEvent.fromMap(String id, Map<String, dynamic> map) {
    return LotHistoryEvent(
      id: id,
      lotId: map['lotId'] as String? ?? '',
      type: map['type'] as String? ?? 'note',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      eventAt: map['eventAt'] as Timestamp? ?? Timestamp.now(),
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}
