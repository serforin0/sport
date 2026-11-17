import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/connections/domain/entities/connected_contact.dart';

void main() {
  test('fromApi toma el ULID del par y no el id numérico de la conexión', () {
    final contact = ConnectedContact.fromApi({
      'id': 42,
      'sender': {
        'id': '01viewerulidxxxxxxxxxxxxxxxxxxxx',
        'name': 'Yo',
        'email': 'me@test.com',
      },
      'recipient': {
        'id': '01peerulidxxxxxxxxxxxxxxxxxxxxxx',
        'name': 'Hugo Pena',
        'email': 'hugo@test.com',
      },
    }, viewerId: '01viewerulidxxxxxxxxxxxxxxxxxxxx');

    expect(contact.connectionId, '42');
    expect(contact.person.user.id, '01peerulidxxxxxxxxxxxxxxxxxxxxxx');
    expect(contact.person.user.name, 'Hugo Pena');
  });

  test('fromApi prefiere user cuando el backend ya envía el par', () {
    final contact = ConnectedContact.fromApi({
      'id': 9,
      'user': {
        'id': '01peerulidxxxxxxxxxxxxxxxxxxxxxx',
        'name': 'Camila Soto',
        'email': 'c@test.com',
      },
    });

    expect(contact.person.user.id, '01peerulidxxxxxxxxxxxxxxxxxxxxxx');
  });
}
