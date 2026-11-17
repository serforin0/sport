import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/auth/domain/entities/meta.dart';
import 'package:sport/features/auth/presentation/providers/meta_providers.dart';
import 'package:sport/features/sponsorships/presentation/providers/sponsorships_providers.dart';
import 'package:sport/features/demo/presentation/widgets/demo_badge.dart';

class CreateSponsorshipPage extends ConsumerStatefulWidget {
  const CreateSponsorshipPage({super.key});

  @override
  ConsumerState<CreateSponsorshipPage> createState() =>
      _CreateSponsorshipPageState();
}

class _CreateSponsorshipPageState extends ConsumerState<CreateSponsorshipPage> {
  final _brandCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _requirementsCtrl = TextEditingController();
  final _benefitsCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  Sport? _sport;
  bool _saving = false;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _typeCtrl.dispose();
    _requirementsCtrl.dispose();
    _benefitsCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_brandCtrl.text.trim().isEmpty ||
        _typeCtrl.text.trim().isEmpty ||
        _requirementsCtrl.text.trim().isEmpty ||
        _benefitsCtrl.text.trim().isEmpty ||
        _sport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos requeridos')),
      );
      return;
    }

    setState(() => _saving = true);
    final result = await ref
        .read(sponsorshipsRepositoryProvider)
        .createSponsorship({
          'brand_name': _brandCtrl.text.trim(),
          'sport_id': _sport!.id,
          'sponsorship_type': _typeCtrl.text.trim(),
          'requirements': _requirementsCtrl.text.trim(),
          'benefits': _benefitsCtrl.text.trim(),
          if (_contactCtrl.text.trim().isNotEmpty)
            'contact': _contactCtrl.text.trim(),
        });

    if (!mounted) return;
    setState(() => _saving = false);
    final ok = result.fold((_) => false, (_) => true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Patrocinio publicado' : 'No se pudo publicar'),
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sportsAsync = ref.watch(sportsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Publicar patrocinio',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Align(alignment: Alignment.centerLeft, child: DemoBadge()),
          const SizedBox(height: 14),
          _Field(label: 'Marca patrocinadora *', controller: _brandCtrl),
          const SizedBox(height: 14),
          sportsAsync.when(
            data: (sports) => DropdownButtonFormField<Sport>(
              initialValue: _sport,
              dropdownColor: const Color(0xFF1E293B),
              decoration: _decoration('Deporte *'),
              style: const TextStyle(color: Colors.white),
              items: sports
                  .map(
                    (sport) =>
                        DropdownMenuItem(value: sport, child: Text(sport.name)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _sport = value),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text(
              'No se pudieron cargar deportes',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          const SizedBox(height: 14),
          _Field(label: 'Tipo de patrocinio *', controller: _typeCtrl),
          const SizedBox(height: 14),
          _Field(
            label: 'Requisitos para aplicar *',
            controller: _requirementsCtrl,
            maxLines: 5,
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Beneficios ofrecidos *',
            controller: _benefitsCtrl,
            maxLines: 5,
          ),
          const SizedBox(height: 14),
          _Field(label: 'Contacto', controller: _contactCtrl),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(_saving ? 'Publicando...' : 'Publicar patrocinio'),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
    );
  }
}

InputDecoration _decoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: const Color(0xFF1E293B),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}
