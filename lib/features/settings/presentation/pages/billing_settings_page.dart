import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/support/presentation/providers/support_providers.dart';
import 'invoices_page.dart';
import 'payment_methods_page.dart';
import 'add_card_page.dart';

class BillingSettingsPage extends ConsumerWidget {
  const BillingSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(billingSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FACTURACIÓN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => ref.invalidate(billingSummaryProvider),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudo cargar el resumen.\n$e',
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (map) {
          final isEmpty = map.isEmpty;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 24, bottom: 16),
                    child: Text(
                      'Resumen de facturación (placeholder desde GET /billing/summary). '
                      'La pasarela de pago se integrará próximamente.',
                      style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.4),
                    ),
                  )
                else ...[
                  const Text(
                    'Datos del servidor',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    const JsonEncoder.withIndent('  ').convert(map),
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 24),
                ],
                const _BillingHeader(title: 'SUSCRIPCIÓN'),
                _BillingTile(
                  icon: Icons.star_outline,
                  title: 'HubSport Premium',
                  subtitle: 'Plan Activo: Profesional',
                  onTap: () {}, // Future: Plan details
                ),
                const SizedBox(height: 16),
                const _BillingHeader(title: 'PAGOS'),
                _BillingTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Métodos de pago',
                  subtitle: 'Visa terminada en 4242',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentMethodsPage()),
                  ),
                ),
                _BillingTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Historial de Pagos',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InvoicesPage()),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.workspace_premium, color: Colors.white, size: 40),
                        SizedBox(height: 12),
                        Text(
                          'Desbloquea todo el potencial',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Accede a estadísticas avanzadas y visibilidad prioritaria.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BillingHeader extends StatelessWidget {
  final String title;
  const _BillingHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF3B82F6),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _BillingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _BillingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 13))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }
}
