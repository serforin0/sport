class UserSettings {
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final SecuritySettings security;

  const UserSettings({
    required this.notifications,
    required this.privacy,
    required this.security,
  });

  UserSettings copyWith({
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    SecuritySettings? security,
  }) {
    return UserSettings(
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      security: security ?? this.security,
    );
  }

  static const defaultSettings = UserSettings(
    notifications: NotificationSettings(
      pushEnabled: true,
      emailEnabled: false,
      messagesEnabled: true,
      opportunitiesEnabled: true,
      tipsEnabled: true,
    ),
    privacy: PrivacySettings(
      publicProfile: true,
      showStats: true,
      allowMessagesFromAnyone: false,
    ),
    security: SecuritySettings(
      is2FAEnabled: false,
    ),
  );
}

class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool messagesEnabled;
  final bool opportunitiesEnabled;
  final bool tipsEnabled;

  const NotificationSettings({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.messagesEnabled,
    required this.opportunitiesEnabled,
    required this.tipsEnabled,
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? messagesEnabled,
    bool? opportunitiesEnabled,
    bool? tipsEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      messagesEnabled: messagesEnabled ?? this.messagesEnabled,
      opportunitiesEnabled: opportunitiesEnabled ?? this.opportunitiesEnabled,
      tipsEnabled: tipsEnabled ?? this.tipsEnabled,
    );
  }
}

class PrivacySettings {
  final bool publicProfile;
  final bool showStats;
  final bool allowMessagesFromAnyone;

  const PrivacySettings({
    required this.publicProfile,
    required this.showStats,
    required this.allowMessagesFromAnyone,
  });

  PrivacySettings copyWith({
    bool? publicProfile,
    bool? showStats,
    bool? allowMessagesFromAnyone,
  }) {
    return PrivacySettings(
      publicProfile: publicProfile ?? this.publicProfile,
      showStats: showStats ?? this.showStats,
      allowMessagesFromAnyone: allowMessagesFromAnyone ?? this.allowMessagesFromAnyone,
    );
  }
}

class SecuritySettings {
  final bool is2FAEnabled;

  const SecuritySettings({
    required this.is2FAEnabled,
  });

  SecuritySettings copyWith({
    bool? is2FAEnabled,
  }) {
    return SecuritySettings(
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
    );
  }
}
