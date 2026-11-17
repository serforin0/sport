import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

MockSharedPreferences createMockPrefs({
  String? token = 'tok',
  String? cachedUser = '{"id":"u1","email":"a@test.com","name":"Ana"}',
}) {
  final prefs = MockSharedPreferences();
  when(() => prefs.getString(any())).thenReturn(null);
  when(() => prefs.getString('auth_token')).thenReturn(token);
  when(() => prefs.getString('cached_user')).thenReturn(cachedUser);
  when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
  when(() => prefs.remove(any())).thenAnswer((_) async => true);
  return prefs;
}
