import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/connections/data/datasources/connections_remote_datasource.dart';
import 'package:sport/features/connections/domain/entities/connected_contact.dart';
import 'package:sport/features/connections/domain/entities/pending_connection.dart';
import 'package:sport/features/people/domain/people_list_user.dart';

class MockConnectionsRemoteDataSource extends Mock
    implements ConnectionsRemoteDataSource {}

void main() {
  late MockConnectionsRemoteDataSource ds;

  setUp(() {
    ds = MockConnectionsRemoteDataSource();
  });

  test('flujo solicitud → incoming → accept → lista aceptados', () async {
    const token = 'tok';
    const pending = PendingConnection(
      connectionId: 'c1',
      userId: 'u2',
      name: 'Peer',
    );
    const accepted = ConnectedContact(
      connectionId: 'c1',
      person: PeopleListUser(
        user: UserModel(id: 'u2', email: 'peer@test.com', name: 'Peer'),
        detailLine: 'Deportista',
      ),
    );

    when(() => ds.sendRequest(token, 'u2')).thenAnswer((_) async {});
    when(() => ds.fetchIncoming(token)).thenAnswer((_) async => [pending]);
    when(() => ds.accept(token, 'c1')).thenAnswer((_) async {});
    when(
      () => ds.fetchAcceptedConnections(
        token,
        viewerId: any(named: 'viewerId'),
      ),
    ).thenAnswer((_) async => [accepted]);

    await ds.sendRequest(token, 'u2');
    final incoming = await ds.fetchIncoming(token);
    expect(incoming.single.connectionId, 'c1');

    await ds.accept(token, 'c1');
    final friends = await ds.fetchAcceptedConnections(token, viewerId: 'u1');
    expect(friends.single.person.user.id, 'u2');

    verifyInOrder([
      () => ds.sendRequest(token, 'u2'),
      () => ds.fetchIncoming(token),
      () => ds.accept(token, 'c1'),
      () => ds.fetchAcceptedConnections(token, viewerId: 'u1'),
    ]);
  });
}
