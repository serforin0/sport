import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/jobs/domain/entities/job_applicant.dart';

class JobApplicantModel extends JobApplicant {
  const JobApplicantModel({
    required super.id,
    required super.status,
    required super.createdAt,
    required super.user,
    super.message,
  });

  factory JobApplicantModel.fromApi(Map<String, dynamic> json) {
    final userRaw = json['user'];

    return JobApplicantModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      message: json['message']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      user: userRaw is Map<String, dynamic>
          ? UserModel.fromMap(userRaw)
          : UserModel.fromMap(Map<String, dynamic>.from(userRaw as Map? ?? const {})),
    );
  }
}
