class CreateLotHistoryEventInput {
  final String lotId;
  final String type;
  final String title;
  final String description;
  final DateTime eventAt;
  final Map<String, dynamic>? metadata;

  const CreateLotHistoryEventInput({
    required this.lotId,
    required this.type,
    required this.title,
    required this.description,
    required this.eventAt,
    this.metadata,
  });
}
