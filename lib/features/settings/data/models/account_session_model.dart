import 'package:sport/features/settings/domain/entities/account_session.dart';

class AccountSessionModel extends AccountSession {
  const AccountSessionModel({
    required super.id,
    required super.lastActivity,
    required super.isCurrent,
    super.ipAddress,
    super.userAgent,
  });

  factory AccountSessionModel.fromMap(Map<String, dynamic> map) {
    return AccountSessionModel(
      id: map['id']?.toString() ?? '',
      ipAddress: map['ip_address']?.toString(),
      userAgent: map['user_agent']?.toString(),
      lastActivity: map['last_activity'] != null ? DateTime.tryParse(map['last_activity'].toString()) ?? DateTime.now() : DateTime.now(),
      isCurrent: map['is_current'] == true,
    );
  }
}
