import 'package:sport/features/settings/domain/entities/user_settings.dart';

class UserSettingsModel extends UserSettings {
  const UserSettingsModel({
    required super.notifications,
    required super.privacy,
    required super.security,
  });

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      notifications: NotificationSettingsModel.fromMap(map['notifications']),
      privacy: PrivacySettingsModel.fromMap(map['privacy']),
      security: SecuritySettingsModel.fromMap(map['security']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': (notifications as NotificationSettingsModel).toMap(),
      'privacy': (privacy as PrivacySettingsModel).toMap(),
      'security': (security as SecuritySettingsModel).toMap(),
    };
  }

  factory UserSettingsModel.fromEntity(UserSettings entity) {
    return UserSettingsModel(
      notifications: NotificationSettingsModel.fromEntity(entity.notifications),
      privacy: PrivacySettingsModel.fromEntity(entity.privacy),
      security: SecuritySettingsModel.fromEntity(entity.security),
    );
  }
}

class NotificationSettingsModel extends NotificationSettings {
  const NotificationSettingsModel({
    required super.pushEnabled,
    required super.emailEnabled,
    required super.messagesEnabled,
    required super.opportunitiesEnabled,
    required super.tipsEnabled,
  });

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      pushEnabled: map['pushEnabled'] ?? true,
      emailEnabled: map['emailEnabled'] ?? false,
      messagesEnabled: map['messagesEnabled'] ?? true,
      opportunitiesEnabled: map['opportunitiesEnabled'] ?? map['eventsEnabled'] ?? true,
      tipsEnabled: map['tipsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'messagesEnabled': messagesEnabled,
      'opportunitiesEnabled': opportunitiesEnabled,
      'tipsEnabled': tipsEnabled,
    };
  }

  factory NotificationSettingsModel.fromEntity(NotificationSettings entity) {
    return NotificationSettingsModel(
      pushEnabled: entity.pushEnabled,
      emailEnabled: entity.emailEnabled,
      messagesEnabled: entity.messagesEnabled,
      opportunitiesEnabled: entity.opportunitiesEnabled,
      tipsEnabled: entity.tipsEnabled,
    );
  }
}

class PrivacySettingsModel extends PrivacySettings {
  const PrivacySettingsModel({
    required super.publicProfile,
    required super.showStats,
    required super.allowMessagesFromAnyone,
  });

  factory PrivacySettingsModel.fromMap(Map<String, dynamic> map) {
    return PrivacySettingsModel(
      publicProfile: map['publicProfile'] ?? true,
      showStats: map['showStats'] ?? true,
      allowMessagesFromAnyone: map['allowMessagesFromAnyone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'publicProfile': publicProfile,
      'showStats': showStats,
      'allowMessagesFromAnyone': allowMessagesFromAnyone,
    };
  }

  factory PrivacySettingsModel.fromEntity(PrivacySettings entity) {
    return PrivacySettingsModel(
      publicProfile: entity.publicProfile,
      showStats: entity.showStats,
      allowMessagesFromAnyone: entity.allowMessagesFromAnyone,
    );
  }
}

class SecuritySettingsModel extends SecuritySettings {
  const SecuritySettingsModel({
    required super.is2FAEnabled,
  });

  factory SecuritySettingsModel.fromMap(Map<String, dynamic> map) {
    return SecuritySettingsModel(
      is2FAEnabled: map['is2FAEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is2FAEnabled': is2FAEnabled,
    };
  }

  factory SecuritySettingsModel.fromEntity(SecuritySettings entity) {
    return SecuritySettingsModel(
      is2FAEnabled: entity.is2FAEnabled,
    );
  }
}
