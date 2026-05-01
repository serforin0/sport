import 'package:sport/features/people/domain/people_list_user.dart';

/// Amigo aceptado (`GET /connections`).
class ConnectedContact {
  final String connectionId;
  final PeopleListUser person;

  const ConnectedContact({
    required this.connectionId,
    required this.person,
  });
}
