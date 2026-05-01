import 'package:flutter/material.dart';

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _InvoiceItem(
            id: 'INV-2024-001',
            date: '28 Mar 2024',
            amount: '€19.99',
            status: 'Pagado',
            description: 'HubSport Premium - Mensual',
          ),
          const _InvoiceItem(
            id: 'INV-2024-002',
            date: '28 Feb 2024',
            amount: '€19.99',
            status: 'Pagado',
            description: 'HubSport Premium - Mensual',
          ),
          const _InvoiceItem(
            id: 'INV-2024-003',
            date: '28 Ene 2024',
            amount: '€19.99',
            status: 'Pagado',
            description: 'HubSport Premium - Mensual',
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Mostrando las últimas 3 facturas',
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceItem extends StatelessWidget {
  final String id;
  final String date;
  final String amount;
  final String status;
  final String description;

  const _InvoiceItem({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
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
                  const Text('FECHA', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('TOTAL', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(amount, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
