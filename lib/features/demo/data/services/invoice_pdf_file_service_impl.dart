import 'dart:typed_data';

import 'package:printing/printing.dart';
import 'package:sport/features/demo/domain/services/invoice_pdf_file_service.dart';

class InvoicePdfFileServiceImpl implements InvoicePdfFileService {
  const InvoicePdfFileServiceImpl();

  @override
  Future<void> share(Uint8List bytes, String filename) {
    return Printing.sharePdf(bytes: bytes, filename: _safeFilename(filename));
  }

  String _safeFilename(String value) {
    final normalized = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '-');
    return normalized.toLowerCase().endsWith('.pdf')
        ? normalized
        : '$normalized.pdf';
  }
}
