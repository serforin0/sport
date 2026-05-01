import 'package:sport/features/auth/domain/entities/user.dart';

class SportsReference {
  final String id;
  final String? requestId;
  final String relationshipType;
  final String body;
  final String status;
  final bool isSuspicious;
  final String? suspiciousReason;
  final User? author;
  final DateTime createdAt;

  const SportsReference({
    required this.id,
    required this.relationshipType,
    required this.body,
    required this.status,
    required this.isSuspicious,
    required this.createdAt,
    this.requestId,
    this.suspiciousReason,
    this.author,
  });
}
