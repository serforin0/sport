import 'package:flutter/material.dart';
import 'package:sport/features/demo/presentation/widgets/demo_badge.dart';

class AddCardPage extends StatelessWidget {
  const AddCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('MÉTODO DE PAGO DEMO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DemoBadge(),
            const SizedBox(height: 24),
            const Icon(
              Icons.credit_card_off_outlined,
              color: Color(0xFF60A5FA),
              size: 56,
            ),
            const SizedBox(height: 20),
            const Text(
              'No introduzcas datos de tarjeta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta vista nunca solicita ni almacena PAN, fecha de vencimiento '
              'o CVV. Agregar un método de pago es únicamente una simulación '
              'informativa.',
              style: TextStyle(color: Colors.white60, height: 1.5),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => showDemoSimulation(
                  context,
                  'No se guardó ningún dato ni se contactó una pasarela de pago.',
                ),
                child: const Text('SIMULAR MÉTODO DE PAGO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
