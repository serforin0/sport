import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/demo/data/repositories/demo_invoice_pdf_repository_impl.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient apiClient;
  late DemoInvoicePdfRepositoryImpl repository;

  setUp(() {
    apiClient = _MockApiClient();
    repository = DemoInvoicePdfRepositoryImpl(apiClient);
  });

  test('descarga bytes PDF válidos', () async {
    when(() => apiClient.get(any(), options: any(named: 'options'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: Uint8List.fromList('%PDF-1.4'.codeUnits),
      ),
    );

    final result = await repository.getInvoicePdf('inv_demo_2026_08');

    expect(result.isSuccess, isTrue);
    result.fold(
      (_) => fail('Se esperaba un PDF'),
      (bytes) => expect(String.fromCharCodes(bytes.take(5)), '%PDF-'),
    );
  });

  test('rechaza una respuesta que no es PDF', () async {
    when(() => apiClient.get(any(), options: any(named: 'options'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: Uint8List.fromList('not-pdf'.codeUnits),
      ),
    );

    final result = await repository.getInvoicePdf('inv_demo_2026_08');

    expect(result.isFailure, isTrue);
  });

  test('convierte errores de red en fallo seguro', () async {
    when(
      () => apiClient.get(any(), options: any(named: 'options')),
    ).thenThrow(Exception('detalle interno'));

    final result = await repository.getInvoicePdf('inv_demo_2026_08');

    expect(result.isFailure, isTrue);
    result.fold(
      (failure) => expect(failure.message, 'No se pudo descargar la factura'),
      (_) => fail('Se esperaba un fallo'),
    );
  });
}
