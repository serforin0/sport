import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/auth/domain/entities/meta.dart';
import 'package:sport/features/auth/presentation/providers/meta_providers.dart';
import 'package:sport/features/events/presentation/providers/events_providers.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({super.key});

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();
  final _organizerCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _routeCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  Sport? _sport;
  String? _eventType = 'race';
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  static const _types = [
    ('race', 'Carrera'),
    ('clinic', 'Clínica'),
    ('meetup', 'Encuentro'),
    ('training', 'Entrenamiento'),
    ('other', 'Otro'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _descriptionCtrl.dispose();
    _photoCtrl.dispose();
    _organizerCtrl.dispose();
    _contactCtrl.dispose();
    _routeCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _locationCtrl.text.trim().isEmpty ||
        _descriptionCtrl.text.trim().isEmpty ||
        _organizerCtrl.text.trim().isEmpty ||
        _contactCtrl.text.trim().isEmpty ||
        _sport == null ||
        _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos requeridos')),
      );
      return;
    }

    setState(() => _saving = true);
    final ok = await ref.read(eventsListProvider.notifier).createEvent({
      'name': _nameCtrl.text.trim(),
      'event_date': '${_date!.year.toString().padLeft(4, '0')}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
      if (_time != null) 'event_time': '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}',
      'location': _locationCtrl.text.trim(),
      if (_routeCtrl.text.trim().isNotEmpty) 'route_text': _routeCtrl.text.trim(),
      if (_cityCtrl.text.trim().isNotEmpty) 'city': _cityCtrl.text.trim(),
      if (_countryCtrl.text.trim().isNotEmpty) 'country': _countryCtrl.text.trim(),
      'sport_id': _sport!.id,
      'description': _descriptionCtrl.text.trim(),
      if (_photoCtrl.text.trim().isNotEmpty) 'photo_url': _photoCtrl.text.trim(),
      'organizer_name': _organizerCtrl.text.trim(),
      'organizer_contact': _contactCtrl.text.trim(),
      if (_eventType != null) 'event_type': _eventType,
      if (_capacityCtrl.text.trim().isNotEmpty)
        'capacity': int.tryParse(_capacityCtrl.text.trim()),
    });

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Evento creado' : 'No se pudo crear el evento')),
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
        title: const Text('Crear evento', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Field(label: 'Nombre del evento *', controller: _nameCtrl),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _eventType,
            dropdownColor: const Color(0xFF1E293B),
            decoration: _decoration('Tipo de evento'),
            style: const TextStyle(color: Colors.white),
            items: _types
                .map(
                  (t) => DropdownMenuItem(value: t.$1, child: Text(t.$2)),
                )
                .toList(),
            onChanged: (value) => setState(() => _eventType = value),
          ),
          const SizedBox(height: 14),
          sportsAsync.when(
            data: (sports) => DropdownButtonFormField<Sport>(
              value: _sport,
              dropdownColor: const Color(0xFF1E293B),
              decoration: _decoration('Deporte *'),
              style: const TextStyle(color: Colors.white),
              items: sports.map((sport) => DropdownMenuItem(value: sport, child: Text(sport.name))).toList(),
              onChanged: (value) => setState(() => _sport = value),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('No se pudieron cargar deportes', style: TextStyle(color: Colors.redAccent)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PickerTile(
                  label: _date == null ? 'Fecha *' : '${_date!.day}/${_date!.month}/${_date!.year}',
                  icon: Icons.calendar_today,
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickerTile(
                  label: _time == null ? 'Hora' : _time!.format(context),
                  icon: Icons.schedule,
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Field(label: 'Ubicación *', controller: _locationCtrl),
          const SizedBox(height: 14),
          _Field(label: 'Ruta (texto)', controller: _routeCtrl),
          const SizedBox(height: 14),
          _Field(
            label: 'Cupo (opcional)',
            controller: _capacityCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _Field(label: 'Ciudad', controller: _cityCtrl),
          const SizedBox(height: 14),
          _Field(label: 'País', controller: _countryCtrl),
          const SizedBox(height: 14),
          _Field(label: 'Fotografía del evento URL', controller: _photoCtrl),
          const SizedBox(height: 14),
          _Field(label: 'Nombre del organizador *', controller: _organizerCtrl),
          const SizedBox(height: 14),
          _Field(label: 'Contacto del organizador *', controller: _contactCtrl),
          const SizedBox(height: 14),
          _Field(label: 'Descripción *', controller: _descriptionCtrl, maxLines: 6),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(_saving ? 'Publicando...' : 'Publicar evento'),
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
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerTile({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
          ],
        ),
      ),
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
