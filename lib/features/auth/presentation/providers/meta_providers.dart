import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/meta.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final metaRepositoryProvider = Provider<MetaRepository>((ref) {
  return MetaRepository(ref.watch(apiClientProvider));
});

class MetaRepository {
  final ApiClient apiClient;
  MetaRepository(this.apiClient);

  static final Set<String> _realSportNames = {
    'natacion',
    'natación',
    'futbol',
    'fútbol',
    'voleibol',
    'baloncesto',
    'tenis',
    'badminton',
    'bádminton',
    'beisbol',
    'béisbol',
    'balonmano',
    'hockey',
    'rugby',
    'formula 1',
    'fórmula 1',
    'boxeo',
    'atletismo',
    'gimnasia',
    'ciclismo',
    'golf',
    'artes marciales',
    'mma',
  };

  static final List<Sport> _fallbackSports = [
    Sport(id: '01kmtfvygv7d4d3c0eh97d3zzc', name: 'Natación'),
    Sport(id: '01kmtfvygwy3thkdx00kk99s4x', name: 'Fútbol'),
    Sport(id: '01kmtfvygx271vbkwqvhzgxy88', name: 'Voleibol'),
    Sport(id: '01kmtfvygzwgw9pt9kpf4mqfa6', name: 'Baloncesto'),
    Sport(id: '01kmtfvyh0ydh39qqakb99n264', name: 'Tenis'),
    Sport(id: '01kmtfvyh1k343h6p3ddzemcqr', name: 'Bádminton'),
    Sport(id: '01kmtfvyh2h5er7zt97e118v0v', name: 'Béisbol'),
    Sport(id: '01kmtfvyh4r1fmz4gw6qbws7jn', name: 'Balonmano'),
    Sport(id: '01kmtfvyh4r1fmz4gw6qbws7jp', name: 'Hockey'),
    Sport(id: '01kmtfvyh5fyq5y08ak9ay5xck', name: 'Rugby'),
    Sport(id: '01kmtfvyh62n4wsg5zqzezgsj2', name: 'Fórmula 1'),
  ];

  static final List<Country> _fallbackCountries = [
    Country(id: '01KMTFVYH8955Z7RED16TKM94D', name: 'Argentina', code: 'AR'),
    Country(id: '01KMTFVYH8955Z7RED16TKM94J', name: 'República Dominicana', code: 'DO'),
    Country(id: '01KMTFVYH8955Z7RED16TKM94E', name: 'Estados Unidos', code: 'US'),
    Country(id: '01KMTFVYH8955Z7RED16TKM94F', name: 'España', code: 'ES'),
    Country(id: '01KMTFVYH8955Z7RED16TKM94G', name: 'México', code: 'MX'),
    Country(id: '01KMTFVYH8955Z7RED16TKM94H', name: 'Colombia', code: 'CO'),
  ];

  Future<Result<List<Sport>>> getSports() async {
    try {
      final response = await apiClient.get('/sport');
      final data = response.data['data'] as List;
      final sports = data
          .map((e) => Sport.fromMap(Map<String, dynamic>.from(e)))
          .where((sport) => _realSportNames.contains(_normalize(sport.name)))
          .toList();
      return Ok(sports.isEmpty ? _fallbackSports : sports);
    } catch (e) {
      return Ok(_fallbackSports);
    }
  }

  Future<Result<List<Country>>> getCountries() async {
    try {
      final response = await apiClient.get('/countries');
      final data = response.data['data'] as List;
      final countries = data.map((e) => Country.fromMap(Map<String, dynamic>.from(e))).toList();
      return Ok(_mergeFallbackCountries(countries));
    } catch (e) {
      return Ok(_fallbackCountries);
    }
  }

  static List<Country> _mergeFallbackCountries(List<Country> remoteCountries) {
    final byCode = {for (final country in remoteCountries) country.code.toUpperCase(): country};
    for (final country in _fallbackCountries) {
      byCode.putIfAbsent(country.code.toUpperCase(), () => country);
    }
    return byCode.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .trim();
  }
}

final sportsProvider = FutureProvider<List<Sport>>((ref) {
  return ref.watch(metaRepositoryProvider).getSports().then((res) => res.fold((f) => throw f, (s) => s));
});

final countriesProvider = FutureProvider<List<Country>>((ref) {
  return ref.watch(metaRepositoryProvider).getCountries().then((res) => res.fold((f) => throw f, (c) => c));
});
