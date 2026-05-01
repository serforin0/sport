import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/references/data/models/sports_reference_model.dart';
import 'package:sport/features/references/domain/entities/reference_request.dart';

class ReferenceRequestModel extends ReferenceRequestEntity {
  const ReferenceRequestModel({
    required super.id,
    required super.relationshipType,
    required super.status,
    required super.createdAt,
    super.message,
    super.requester,
    super.recipient,
    super.reference,
  });

  factory ReferenceRequestModel.fromApi(Map<String, dynamic> json) {
    final requesterRaw = json['requester'];
    final recipientRaw = json['recipient'];
    final referenceRaw = json['reference'];

    return ReferenceRequestModel(
      id: json['id']?.toString() ?? '',
      relationshipType: json['relationship_type']?.toString() ?? 'Referencia',
      message: json['message']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      requester: requesterRaw is Map ? UserModel.fromMap(Map<String, dynamic>.from(requesterRaw)) : null,
      recipient: recipientRaw is Map ? UserModel.fromMap(Map<String, dynamic>.from(recipientRaw)) : null,
      reference: referenceRaw is Map ? SportsReferenceModel.fromApi(Map<String, dynamic>.from(referenceRaw)) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}
