class AccountSession {
  final String id;
  final String? ipAddress;
  final String? userAgent;
  final DateTime lastActivity;
  final bool isCurrent;

  const AccountSession({
    required this.id,
    required this.lastActivity,
    required this.isCurrent,
    this.ipAddress,
    this.userAgent,
  });
}
