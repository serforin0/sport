import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/events/data/models/sport_event_model.dart';

void main() {
  test('fromApi conserva photo_url absoluta', () {
    final event = SportEventModel.fromApi({
      'id': 'evt-1',
      'name': 'Encuentro Nacional de Velocidad',
      'description': 'Jornada de competencias',
      'location': 'Estadio Olímpico',
      'event_date': '2026-12-05',
      'organizer_name': 'Club Horizonte',
      'organizer_contact': 'eventos@hubsport.test',
      'photo_url': 'https://images.unsplash.com/photo-1461896836934-ffe607ba6851?w=1200',
      'sport': {'name': 'Atletismo'},
    });

    expect(event.photoUrl, contains('https://'));
    expect(event.photoUrl, isNot(contains('example.test')));
    expect(event.sportName, 'Atletismo');
  });
}
