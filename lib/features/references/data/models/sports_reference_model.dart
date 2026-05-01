import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/references/domain/entities/sports_reference.dart';

class SportsReferenceModel extends SportsReference {
  const SportsReferenceModel({
    required super.id,
    required super.relationshipType,
    required super.body,
    required super.status,
    required super.isSuspicious,
    required super.createdAt,
    super.requestId,
    super.suspiciousReason,
    super.author,
  });

  factory SportsReferenceModel.fromApi(Map<String, dynamic> json) {
    final authorRaw = json['author'];

    return SportsReferenceModel(
      id: json['id']?.toString() ?? '',
      requestId: json['reference_request_id']?.toString(),
      relationshipType: json['relationship_type']?.toString() ?? 'Referencia',
      body: json['body']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending_confirmation',
      isSuspicious: json['is_suspicious'] == true,
      suspiciousReason: json['suspicious_reason']?.toString(),
      author: authorRaw is Map ? UserModel.fromMap(Map<String, dynamic>.from(authorRaw)) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}
