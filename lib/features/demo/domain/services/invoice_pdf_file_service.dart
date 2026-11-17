import 'dart:typed_data';

abstract class InvoicePdfFileService {
  Future<void> share(Uint8List bytes, String filename);
}
