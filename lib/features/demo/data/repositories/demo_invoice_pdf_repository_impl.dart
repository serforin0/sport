import 'dart:typed_data';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/demo/domain/repositories/demo_invoice_pdf_repository.dart';

class DemoInvoicePdfRepositoryImpl implements DemoInvoicePdfRepository {
  final ApiClient apiClient;

  const DemoInvoicePdfRepositoryImpl(this.apiClient);

  @override
  Future<Result<Uint8List>> getInvoicePdf(String invoiceId) async {
    try {
      final response = await apiClient.get(
        '/demo/invoices/$invoiceId/pdf',
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': 'application/pdf'},
        ),
      );
      final raw = response.data;
      final bytes = raw is Uint8List
          ? raw
          : raw is List<int>
          ? Uint8List.fromList(raw)
          : null;

      if (bytes == null ||
          bytes.length < 5 ||
          String.fromCharCodes(bytes.take(5)) != '%PDF-') {
        return Err(
          ValidationFailure('El documento recibido no es un PDF válido'),
        );
      }

      return Ok(bytes);
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Invoice PDF download failed',
        name: 'DemoInvoicePdfRepository',
        error: error,
        stackTrace: stackTrace,
      );
      return Err(ServerFailure('No se pudo descargar la factura'));
    }
  }
}
