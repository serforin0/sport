import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/demo/domain/entities/demo_showcase.dart';
import 'package:sport/features/demo/presentation/providers/demo_showcase_providers.dart';

class SponsorshipDetailPage extends ConsumerStatefulWidget {
  final DemoCollaboration sponsorship;

  const SponsorshipDetailPage({super.key, required this.sponsorship});

  @override
  ConsumerState<SponsorshipDetailPage> createState() =>
      _SponsorshipDetailPageState();
}

class _SponsorshipDetailPageState extends ConsumerState<SponsorshipDetailPage> {
  bool _busy = false;
  bool _sent = false;

  Future<void> _apply() async {
    setState(() => _busy = true);
    final result = await ref
        .read(demoShowcaseRepositoryProvider)
        .applySponsorship(
          widget.sponsorship.id,
          message: 'Solicito apoyo para la temporada y el encuentro nacional.',
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _sent = result.isSuccess;
    });
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitud enviada. El equipo de alianzas te contactará.',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.sponsorship;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(item.title, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            item.status,
            style: const TextStyle(
              color: Color(0xFFFBBF24),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.sport != null)
            Text(item.sport!, style: const TextStyle(color: Colors.white54)),
          if (item.partner != null)
            Text(item.partner!, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),
          const Text(
            'Detalle',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description ?? '',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 20),
          const Text(
            'Beneficios',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.benefits ?? 'Apoyo simulado para la temporada.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 20),
          const Text(
            'Requisitos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.requirements ??
                'Disponibilidad durante el calendario competitivo.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          if (item.contact != null) ...[
            const SizedBox(height: 20),
            const Text(
              'Contacto',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(item.contact!, style: const TextStyle(color: Colors.white70)),
          ],
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _busy || _sent ? null : _apply,
            child: Text(_sent ? 'Solicitud enviada' : 'Solicitar apoyo'),
          ),
        ],
      ),
    );
  }
}
