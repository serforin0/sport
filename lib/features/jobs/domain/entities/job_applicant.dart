import 'package:sport/features/auth/domain/entities/user.dart';

class JobApplicant {
  final String id;
  final String status;
  final String? message;
  final DateTime createdAt;
  final User user;

  const JobApplicant({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.user,
    this.message,
  });
}
