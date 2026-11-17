import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:sport/features/demo/domain/entities/demo_showcase.dart';
import 'package:sport/features/demo/presentation/providers/demo_invoice_pdf_providers.dart';
import 'package:sport/features/demo/presentation/widgets/demo_badge.dart';
import 'package:sport/features/demo/presentation/widgets/demo_error_view.dart';

class InvoicePdfPage extends ConsumerStatefulWidget {
  final DemoInvoice invoice;

  const InvoicePdfPage({super.key, required this.invoice});

  @override
  ConsumerState<InvoicePdfPage> createState() => _InvoicePdfPageState();
}

class _InvoicePdfPageState extends ConsumerState<InvoicePdfPage> {
  bool _busy = false;

  String get _filename => '${widget.invoice.number}.pdf';

  Future<void> _share(Uint8List bytes) async {
    setState(() => _busy = true);
    try {
      await ref.read(invoicePdfFileServiceProvider).share(bytes, _filename);
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo compartir la factura')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = ref.watch(demoInvoicePdfProvider(widget.invoice.id));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(widget.invoice.number),
        actions: [
          const Center(child: DemoBadge()),
          if (document.valueOrNull case final bytes?)
            IconButton(
              tooltip: 'Compartir o guardar PDF',
              onPressed: _busy ? null : () => _share(bytes),
              icon: const Icon(Icons.share_outlined),
            ),
        ],
      ),
      body: document.when(
        loading: () => Center(
          child: Semantics(
            label: 'Cargando factura PDF',
            child: const CircularProgressIndicator(),
          ),
        ),
        error: (_, _) => DemoErrorView(
          message: 'No se pudo abrir la factura.',
          onRetry: () =>
              ref.invalidate(demoInvoicePdfProvider(widget.invoice.id)),
        ),
        data: (bytes) => Semantics(
          container: true,
          label:
              'Factura ${widget.invoice.number}. '
              'Fecha ${widget.invoice.date}. '
              '${widget.invoice.description}. '
              'Estado ${widget.invoice.status}. '
              'Total ${widget.invoice.amount} ${widget.invoice.currency}. '
              'Documento demo sin valor fiscal.',
          child: ExcludeSemantics(
            child: PdfPreview(
              build: (_) async => bytes,
              allowPrinting: false,
              allowSharing: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              pdfFileName: _filename,
              loadingWidget: const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Preparando vista previa PDF',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
