import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/references/domain/entities/sports_reference.dart';

class ReferenceRequestEntity {
  final String id;
  final String relationshipType;
  final String? message;
  final String status;
  final User? requester;
  final User? recipient;
  final SportsReference? reference;
  final DateTime createdAt;

  const ReferenceRequestEntity({
    required this.id,
    required this.relationshipType,
    required this.status,
    required this.createdAt,
    this.message,
    this.requester,
    this.recipient,
    this.reference,
  });
}

class ReferencesInbox {
  final List<ReferenceRequestEntity> received;
  final List<ReferenceRequestEntity> sent;

  const ReferencesInbox({required this.received, required this.sent});
}
