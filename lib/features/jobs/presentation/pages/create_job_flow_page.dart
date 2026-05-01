import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/jobs_providers.dart';

class CreateJobFlowPage extends ConsumerStatefulWidget {
  const CreateJobFlowPage({super.key});

  @override
  ConsumerState<CreateJobFlowPage> createState() => _CreateJobFlowPageState();
}

class _CreateJobFlowPageState extends ConsumerState<CreateJobFlowPage> {
  String? _role;
  String? _sport;
  String? _company;
  String? _companyWebsite;
  String? _companyDescription;
  String? _location;
  String? _contractType;
  String? _applyMethod;
  DateTime? _deadline;
  bool _saving = false;

  bool get _canContinue =>
      _role != null &&
      _sport != null &&
      _company != null &&
      _location != null &&
      _contractType != null &&
      _applyMethod != null &&
      _deadline != null &&
      !_saving;

  Future<void> _publishJob() async {
    if (!_canContinue) return;

    setState(() => _saving = true);
    final result = await ref.read(jobsRepositoryProvider).createJob({
      'title': _role,
      'company': _company,
      'location': _location,
      'contract_type': _contractType,
      'application_type': _applyMethod == 'Sitio web externo' ? 'web' : 'simple',
      if (_applyMethod == 'Sitio web externo' && (_companyWebsite ?? '').isNotEmpty) 'application_url': _companyWebsite,
      'description': _companyDescription?.trim().isNotEmpty == true
          ? _companyDescription
          : 'Oferta para $_role en $_company relacionada con $_sport.',
      if (_deadline != null) 'deadline': _deadline!.toIso8601String().split('T').first,
    });

    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ref.invalidate(jobsListProvider);
        ref.invalidate(myJobOffersProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empleo publicado')));
        Navigator.pop(context, true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
        title: const Text(
          'Publicación de empleo',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
          children: [
            const Text(
              'Completa los detalles generales del puesto de trabajo para obtener resultados más eficientes en la selección de candidatos.',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.45, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 26),
            _JobFormRow(
              title: 'Cargo',
              value: _role ?? 'Seleccionar un cargo',
              onTap: () async {
                final value = await _pushPicker('Cargo', _roles);
                if (value != null) setState(() => _role = value);
              },
            ),
            _JobFormRow(
              title: 'Deporte',
              value: _sport ?? 'Seleccionar un deporte',
              onTap: () async {
                final value = await _pushPicker('Deporte', _sports);
                if (value != null) setState(() => _sport = value);
              },
            ),
            _JobFormRow(
              title: 'Empresa',
              value: _company ?? 'Seleccionar o ingresar empresa',
              detail: _companyDescription,
              onTap: () async {
                final company = await Navigator.push<_CompanyDraft>(
                  context,
                  MaterialPageRoute(builder: (_) => _CompanyJobPage(initial: _CompanyDraft(_company, _companyWebsite, _companyDescription))),
                );
                if (company != null) {
                  setState(() {
                    _company = company.name;
                    _companyWebsite = company.website;
                    _companyDescription = company.description;
                  });
                }
              },
            ),
            _JobFormRow(
              title: 'Ubicación',
              value: _location ?? 'Seleccionar ubicación',
              onTap: () async {
                final value = await _pushPicker('Ubicación', _locations);
                if (value != null) setState(() => _location = value);
              },
            ),
            _JobFormRow(
              title: 'Tipo de contrato',
              value: _contractType ?? 'Seleccionar contrato',
              onTap: () async {
                final value = await _showOptionSheet(_contractTypes);
                if (value != null) setState(() => _contractType = value);
              },
            ),
            _JobFormRow(
              title: 'Método de aplicación',
              value: _applyMethod ?? 'Seleccionar método',
              onTap: () async {
                final value = await _showOptionSheet(const ['Simple', 'Sitio web externo']);
                if (value != null) setState(() => _applyMethod = value);
              },
            ),
            _JobFormRow(
              title: 'Fecha límite de aplicación',
              value: _deadline == null ? 'Seleccionar fecha' : '${_deadline!.day.toString().padLeft(2, '0')}/${_deadline!.month.toString().padLeft(2, '0')}/${_deadline!.year}',
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _deadline = date);
              },
            ),
            const SizedBox(height: 34),
            _GradientButton(
              text: _saving ? 'Publicando...' : 'Siguiente',
              enabled: _canContinue,
              onPressed: _publishJob,
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pushPicker(String title, List<String> items) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => JobPickerPage(title: title, items: items)),
    );
  }

  Future<String?> _showOptionSheet(List<String> options) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 72,
                height: 5,
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
              ),
              for (final option in options)
                ListTile(
                  title: Text(option, style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 15)),
                  onTap: () => Navigator.pop(context, option),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobFormRow extends StatelessWidget {
  final String title;
  final String value;
  final String? detail;
  final VoidCallback onTap;

  const _JobFormRow({required this.title, required this.value, this.detail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1C4B8F)))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: title,
                      style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
                      children: const [TextSpan(text: '*', style: TextStyle(color: Color(0xFFFF7A1A)))],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: TextStyle(
                      color: value.startsWith('Seleccionar') ? const Color(0xFF7D91AC) : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  if (detail != null && detail!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      detail!,
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.35),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.edit, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class JobPickerPage extends StatefulWidget {
  final String title;
  final List<String> items;

  const JobPickerPage({super.key, required this.title, required this.items});

  @override
  State<JobPickerPage> createState() => _JobPickerPageState();
}

class _JobPickerPageState extends State<JobPickerPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.toLowerCase();
    final items = widget.items.where((item) => item.toLowerCase().contains(query)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 74,
        backgroundColor: const Color(0xFF0F2A5B),
        leading: const BackButton(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 52,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1C4B8F)), bottom: BorderSide(color: Color(0xFF1C4B8F))),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                hintStyle: TextStyle(color: Color(0xFF9AB0CC)),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  shape: const Border(bottom: BorderSide(color: Color(0xFF1C4B8F))),
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyJobPage extends StatefulWidget {
  final _CompanyDraft initial;

  const _CompanyJobPage({required this.initial});

  @override
  State<_CompanyJobPage> createState() => _CompanyJobPageState();
}

class _CompanyJobPageState extends State<_CompanyJobPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _webCtrl;
  late final TextEditingController _descriptionCtrl;

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty && _webCtrl.text.trim().isNotEmpty && _descriptionCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial.name);
    _webCtrl = TextEditingController(text: widget.initial.website);
    _descriptionCtrl = TextEditingController(text: widget.initial.description);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _webCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 74,
        backgroundColor: const Color(0xFF0F2A5B),
        leading: const BackButton(color: Colors.white),
        title: const Text('Empresa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          const CircleAvatar(
            radius: 58,
            backgroundColor: Color(0xFFD8F7FF),
            child: Icon(Icons.business_center_outlined, color: Color(0xFF19B5FF), size: 54),
          ),
          const SizedBox(height: 22),
          _CompanyField(label: 'Empresa*', hint: 'Ingresar nombre de la empresa', controller: _nameCtrl, onChanged: () => setState(() {})),
          _CompanyField(label: 'Sitio web', hint: 'Ingresar url de la empresa', controller: _webCtrl, onChanged: () => setState(() {})),
          _CompanyField(label: 'Descripción*', hint: 'Ingresar descripción sobre la empresa', controller: _descriptionCtrl, maxLines: 5, onChanged: () => setState(() {})),
          const SizedBox(height: 46),
          _GradientButton(
            text: 'Guardar',
            enabled: _canSave,
            onPressed: () => Navigator.pop(
              context,
              _CompanyDraft(_nameCtrl.text.trim(), _webCtrl.text.trim(), _descriptionCtrl.text.trim()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final VoidCallback onChanged;

  const _CompanyField({required this.label, required this.hint, required this.controller, required this.onChanged, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: (_) => onChanged(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF7D91AC), fontSize: 12),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF9AB0CC))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback onPressed;

  const _GradientButton({required this.text, required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(colors: [Color(0xFF55B7FF), Color(0xFF1767D9)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
              : null,
          color: enabled ? null : const Color(0xFF9AB0CC),
          borderRadius: BorderRadius.circular(28),
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ),
    );
  }
}

class _CompanyDraft {
  final String? name;
  final String? website;
  final String? description;

  const _CompanyDraft(this.name, this.website, this.description);
}

const _roles = [
  'Entrenador',
  'Encargado',
  'Reclutador',
  'Auxiliar',
  'Administrador',
  'Gerente',
  'Asistente',
  'Director',
  'Analista',
  'Jugador',
  'Entrenador personal',
  'Propietario',
];

const _sports = [
  'Tenis',
  'Atletismo',
  'Fútbol',
  'Baloncesto',
  'Baseball',
  'Natación',
  'Boxeo',
  'Karate',
  'Voleibol',
  'Ciclismo',
];

const _locations = [
  'Valencia, España',
  'Atlanta, Estados Unidos',
  'New York, Estados Unidos',
  'Los Angeles, Estados Unidos',
  'Distrito Nacional, Santo Domingo',
  'Londres, Inglaterra',
  'Texas, Estados Unidos',
  'Sao Paulo, Brazil',
  'Medellín, Colombia',
  'Bogotá, Colombia',
  'Perú',
  'Ciudad de México, México',
];

const _contractTypes = [
  'Jornada completa',
  'Media jornada',
  'Temporal',
  'Prácticas',
  'Freelance',
  'Por contrato',
  'Voluntariado',
];
