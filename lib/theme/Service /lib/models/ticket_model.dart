class TicketModel {
  const TicketModel({
    required this.id,
    required this.title,
    required this.user,
    required this.location,
    required this.device,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.resolutionNote,
    this.proofImagePath,
    this.hasAudio = false,
  });

  final String id;
  final String title;
  final String user;
  final String location;
  final String device;
  final String priority;
  final String status;
  final DateTime createdAt;
  final String? resolutionNote;
  final String? proofImagePath;
  final bool hasAudio;
}


