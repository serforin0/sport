/// Solicitud entrante (`GET /connections/requests/incoming`).
class PendingConnection {
  final String connectionId;
  final String userId;
  final String name;
  final String? photoUrl;
  final String roleLabel;

  const PendingConnection({
    required this.connectionId,
    required this.userId,
    required this.name,
    this.photoUrl,
    this.roleLabel = 'Deportista',
  });
}
