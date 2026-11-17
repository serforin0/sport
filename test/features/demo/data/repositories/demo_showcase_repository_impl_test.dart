import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/demo/data/repositories/demo_showcase_repository_impl.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient apiClient;
  late DemoShowcaseRepositoryImpl repository;

  setUp(() {
    apiClient = _MockApiClient();
    repository = DemoShowcaseRepositoryImpl(apiClient);
  });

  Response<dynamic> jsonResponse(Object? data) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
    );
  }

  test('getShowcase parsea data válida', () async {
    when(() => apiClient.get(any())).thenAnswer(
      (_) async => jsonResponse({
        'data': {
          'billing': {
            'subscription': null,
            'payment_methods': [],
            'invoices': [],
          },
          'groups': [],
          'collaborations': [],
          'store_products': [],
          'sponsorships': [],
        },
      }),
    );

    final result = await repository.getShowcase();
    expect(result.isSuccess, isTrue);
  });

  test('getShowcase rechaza payload inválido', () async {
    when(
      () => apiClient.get(any()),
    ).thenAnswer((_) async => jsonResponse({'data': 'no-map'}));

    final result = await repository.getShowcase();
    expect(result.isFailure, isTrue);
  });

  test('getShowcase convierte excepciones en ServerFailure', () async {
    when(() => apiClient.get(any())).thenThrow(Exception('network'));

    final result = await repository.getShowcase();
    expect(result.isFailure, isTrue);
    result.fold(
      (f) => expect(f.message, contains('demostración')),
      (_) => fail('esperado fallo'),
    );
  });

  test('joinGroup leaveGroup postInGroup y applySponsorship OK', () async {
    when(
      () => apiClient.post(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => jsonResponse({'ok': true}));

    expect((await repository.joinGroup('1')).isSuccess, isTrue);
    expect((await repository.leaveGroup('1')).isSuccess, isTrue);
    expect((await repository.postInGroup('1', 'hola')).isSuccess, isTrue);
    expect(
      (await repository.applySponsorship('9', message: 'interesado')).isSuccess,
      isTrue,
    );
  });

  test('_post convierte errores en fallo', () async {
    when(
      () => apiClient.post(any(), data: any(named: 'data')),
    ).thenThrow(Exception('boom'));

    final result = await repository.joinGroup('1');
    expect(result.isFailure, isTrue);
  });

  test('checkout OK y validación de respuesta', () async {
    when(() => apiClient.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => jsonResponse({
        'data': {'order_id': 'ord-1', 'status': 'confirmed'},
      }),
    );

    final ok = await repository.checkout(
      productId: 'p1',
      variant: 'M',
      recipientName: 'Ana',
      city: 'SD',
      address: 'Calle 1',
    );
    expect(ok.isSuccess, isTrue);
    ok.fold(
      (_) => fail('esperado ok'),
      (data) => expect(data['order_id'], 'ord-1'),
    );

    when(
      () => apiClient.post(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => jsonResponse({'data': null}));
    final bad = await repository.checkout(
      productId: 'p1',
      variant: 'M',
      recipientName: 'Ana',
      city: 'SD',
      address: 'Calle 1',
    );
    expect(bad.isFailure, isTrue);
  });

  test('checkout convierte excepciones', () async {
    when(
      () => apiClient.post(any(), data: any(named: 'data')),
    ).thenThrow(Exception('checkout down'));

    final result = await repository.checkout(
      productId: 'p1',
      variant: 'M',
      recipientName: 'Ana',
      city: 'SD',
      address: 'Calle 1',
    );
    expect(result.isFailure, isTrue);
  });
}
