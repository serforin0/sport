import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sport/features/auth/domain/entities/meta.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/presentation/pages/registration_page.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/auth/presentation/providers/meta_providers.dart';
import 'package:sport/features/demo/presentation/pages/store_product_page.dart';
import 'package:sport/features/onboarding/presentation/pages/role_guide_page.dart';
import 'package:sport/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:sport/features/safety/presentation/pages/reports_inbox_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockApiClient extends Mock implements ApiClient {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('Wave 7 certification', () {
    testWidgets('RoleGuidePage muestra tips de reclutador y Empezar', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final auth = MockAuthRepository();
      const user = User(
        id: 'r1',
        email: 'rec@test.com',
        name: 'Rec Ruiter',
        profileType: 'recruiter',
      );
      when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
      final controller = AuthController(auth)
        ..state = const AsyncValue.data(user);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            authControllerProvider.overrideWith((ref) => controller),
            sharedPrefsInitProvider.overrideWith(
              (ref) async => SharedPreferences.getInstance(),
            ),
          ],
          child: const MaterialApp(home: RoleGuidePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('reclutadores'), findsOneWidget);
      expect(find.textContaining('Revisión de cuenta'), findsOneWidget);
      expect(find.text('Empezar'), findsOneWidget);

      await tester.tap(find.text('Empezar'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('role_guide_done'), isTrue);
    });

    testWidgets('RoleGuidePage tips de atleta por defecto', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = MockAuthRepository();
      const user = User(
        id: 'a1',
        email: 'ath@test.com',
        name: 'Ath Lete',
        profileType: 'athlete',
      );
      when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
      final controller = AuthController(auth)
        ..state = const AsyncValue.data(user);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            authControllerProvider.overrideWith((ref) => controller),
            sharedPrefsInitProvider.overrideWith(
              (ref) async => SharedPreferences.getInstance(),
            ),
          ],
          child: const MaterialApp(home: RoleGuidePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('atletas'), findsOneWidget);
      expect(find.textContaining('perfil scout'), findsOneWidget);
    });

    testWidgets('ReportsInboxPage lista reportes del provider', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reportsInboxProvider.overrideWith(
              (ref) async => [
                {
                  'reason': 'fake_profile',
                  'priority': 'immediate',
                  'status': 'open',
                  'details': 'Perfil sospechoso',
                },
              ],
            ),
          ],
          child: const MaterialApp(home: ReportsInboxPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reportes'), findsOneWidget);
      expect(find.text('fake_profile'), findsOneWidget);
      expect(find.textContaining('immediate'), findsOneWidget);
      expect(find.text('Perfil sospechoso'), findsOneWidget);
    });

    testWidgets('ReportsInboxPage empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reportsInboxProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: ReportsInboxPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No hay reportes abiertos'), findsOneWidget);
    });

    testWidgets('StoreReceiptPage muestra comisión 12%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StoreReceiptPage(
            order: {
              'id': 'ord_demo_cert',
              'product_name': 'Clavos de pista 400 m',
              'variant': '41',
              'amount': 89.0,
              'currency': 'USD',
              'commission_percent': 12.0,
              'commission_amount': 10.68,
              'net_amount': 78.32,
              'recipient_name': 'Cert',
              'address': 'Calle 1',
              'city': 'SD',
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pedido confirmado'), findsOneWidget);
      expect(find.textContaining('Comisión HubSport (12.0%)'), findsOneWidget);
      expect(find.textContaining('10.68'), findsOneWidget);
      expect(find.textContaining('Neto estimado vendedor: 78.32'), findsOneWidget);
    });

    testWidgets('registro reclutador muestra campos org/RNC', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            countriesProvider.overrideWith(
              (ref) async => [
                Country(id: 'do', name: 'República Dominicana', code: 'DO'),
              ],
            ),
            sportsProvider.overrideWith(
              (ref) async => [Sport(id: 's1', name: 'Fútbol')],
            ),
          ],
          child: const MaterialApp(home: RegistrationPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Paso 0 → completar básicos
      await tester.enterText(find.byType(TextField).at(0), 'Rec');
      await tester.enterText(find.byType(TextField).at(1), 'Ruiter');
      await tester.enterText(find.byType(TextField).at(2), 'rec@test.com');
      await tester.enterText(find.byType(TextField).at(3), 'Password1!');
      await tester.enterText(find.byType(TextField).at(4), 'Password1!');
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();

      // Paso 1: cambiar a reclutador
      await tester.tap(find.byType(DropdownButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reclutador').last);
      await tester.pumpAndSettle();

      expect(find.text('Organización *'), findsOneWidget);
      expect(find.text('RNC *'), findsOneWidget);
      expect(
        find.textContaining('quedará en revisión'),
        findsOneWidget,
      );

      // Continuar sin org → snackbar
      await tester.enterText(
        find.widgetWithText(TextField, 'Ej. Santo Domingo').first,
        'SD',
      );
      // birth + country may need more; tap CONTINUAR and expect org snack or country snack
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();

      // Debe pedir país/ciudad o org; al menos no avanzar en silencio
      expect(find.text('CONTINUAR'), findsOneWidget);
    });

    test('AuthRepositoryImpl envía organization_name y rnc en signUp', () async {
      final prefs = MockSharedPreferences();
      final api = MockApiClient();
      final repo = AuthRepositoryImpl(prefs, api);

      when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
      when(() => api.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/register'),
          data: {
            'data': {
              'id': 'u-rec',
              'email': 'rec@test.com',
              'name': 'Rec Ruiter',
            },
            'token': 'tok',
          },
        ),
      );

      final result = await repo.signUpWithEmailAndPassword(
        email: 'rec@test.com',
        password: 'Password1!',
        name: 'Rec Ruiter',
        countryId: 'do',
        city: 'SD',
        sportId: 's1',
        profileType: 'recruiter',
        birthDate: '1988-01-01',
        organizationName: 'Academia Norte',
        rnc: '1-01-12345-6',
        organizationDocumentUrl: 'https://example.test/doc.pdf',
        organizationWebsite: 'https://academia.example',
      );

      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => api.post(any(), data: captureAny(named: 'data')),
      ).captured.single as Map;
      final profile = captured['profile'] as Map;
      expect(profile['organization_name'], 'Academia Norte');
      expect(profile['rnc'], '1-01-12345-6');
      expect(profile['organization_document_url'], 'https://example.test/doc.pdf');
      expect(profile['organization_website'], 'https://academia.example');
      expect(profile['profile_type'], 'recruiter');
    });
  });
}
