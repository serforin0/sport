import 'dart:typed_data';

import 'package:sport/core/result/result.dart';

abstract class DemoInvoicePdfRepository {
  Future<Result<Uint8List>> getInvoicePdf(String invoiceId);
}
