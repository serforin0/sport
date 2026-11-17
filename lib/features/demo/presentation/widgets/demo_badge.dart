import 'package:flutter/material.dart';

class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F766E).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2DD4BF)),
      ),
      child: const Text(
        'Vista de demostración',
        style: TextStyle(
          color: Color(0xFF5EEAD4),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

void showDemoSimulation(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Simulación informativa'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
