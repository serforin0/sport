import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/demo/domain/entities/demo_showcase.dart';
import 'package:sport/features/demo/presentation/pages/invoice_pdf_page.dart';
import 'package:sport/features/demo/presentation/providers/demo_showcase_providers.dart';
import 'package:sport/features/demo/presentation/widgets/demo_badge.dart';
import 'package:sport/features/demo/presentation/widgets/demo_error_view.dart';

class InvoicesPage extends ConsumerWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showcase = ref.watch(demoShowcaseProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HISTORIAL DE FACTURAS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: showcase.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Cargando historial de facturas',
          ),
        ),
        error: (_, _) => DemoErrorView(
          message: 'No se pudieron cargar las facturas.',
          onRetry: () => ref.invalidate(demoShowcaseProvider),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Align(alignment: Alignment.centerLeft, child: DemoBadge()),
            const SizedBox(height: 16),
            for (final invoice in data.billing.invoices)
              _InvoiceItem(
                invoice: invoice,
                onOpen: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => InvoicePdfPage(invoice: invoice),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceItem extends StatelessWidget {
  final DemoInvoice invoice;
  final VoidCallback onOpen;

  const _InvoiceItem({required this.invoice, required this.onOpen});

  Color _statusColor() {
    return switch (invoice.status.toLowerCase()) {
      'paid' || 'pagada' => Colors.greenAccent,
      'pending' || 'pendiente' => Colors.amberAccent,
      _ => Colors.redAccent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          'Abrir factura ${invoice.number}, '
          '${invoice.status}, ${invoice.amount} ${invoice.currency}',
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invoice.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                invoice.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FECHA',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        invoice.date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${invoice.amount} ${invoice.currency}',
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.picture_as_pdf_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Abrir PDF'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
