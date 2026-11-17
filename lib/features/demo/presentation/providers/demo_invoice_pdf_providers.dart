import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/demo/data/repositories/demo_invoice_pdf_repository_impl.dart';
import 'package:sport/features/demo/data/services/invoice_pdf_file_service_impl.dart';
import 'package:sport/features/demo/domain/repositories/demo_invoice_pdf_repository.dart';
import 'package:sport/features/demo/domain/services/invoice_pdf_file_service.dart';

final demoInvoicePdfRepositoryProvider = Provider<DemoInvoicePdfRepository>((
  ref,
) {
  return DemoInvoicePdfRepositoryImpl(ref.watch(apiClientProvider));
});

final invoicePdfFileServiceProvider = Provider<InvoicePdfFileService>((ref) {
  return const InvoicePdfFileServiceImpl();
});

final demoInvoicePdfProvider = FutureProvider.family<Uint8List, String>((
  ref,
  invoiceId,
) async {
  final result = await ref
      .watch(demoInvoicePdfRepositoryProvider)
      .getInvoicePdf(invoiceId);
  return result.fold(
    (failure) => throw StateError(failure.message),
    (bytes) => bytes,
  );
});
