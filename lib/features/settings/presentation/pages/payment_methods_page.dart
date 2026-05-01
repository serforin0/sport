import 'package:flutter/material.dart';
import 'add_card_page.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

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
          'MÉTODOS DE PAGO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _CardItem(
                  brand: 'VISA',
                  last4: '4242',
                  expiry: '12/26',
                  isDefault: true,
                ),
                const _CardItem(
                  brand: 'MASTERCARD',
                  last4: '8812',
                  expiry: '09/25',
                  isDefault: false,
                ),
                const SizedBox(height: 16),
                _AddPaymentMethodTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddCardPage()),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Tus pagos están protegidos con encriptación de extremo a extremo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final String brand;
  final String last4;
  final String expiry;
  final bool isDefault;

  const _CardItem({
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDefault ? const Color(0xFF3B82F6).withOpacity(0.5) : Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              brand == 'VISA' ? Icons.credit_card : Icons.credit_card_outlined,
              color: const Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$brand •••• $last4',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expira el $expiry',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('PRINCIPAL', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _AddPaymentMethodTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPaymentMethodTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10, style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF3B82F6), size: 20),
            SizedBox(width: 8),
            Text(
              'Agregar nuevo método de pago',
              style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
