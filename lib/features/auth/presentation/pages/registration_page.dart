import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_providers.dart';
import '../providers/meta_providers.dart';
import 'package:sport/features/auth/domain/entities/meta.dart';


class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  int _currentStep = 0;
  final _pageController = PageController();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _teamCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _xCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  
  Country? _selectedCountry;
  final List<String> _selectedSportIds = [];
  String _selectedProfileType = 'athlete';
  String? _selectedSportLevel;
  File? _avatarFile;
  bool _acceptedTerms = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _positionCtrl.dispose();
    _teamCtrl.dispose();
    _instagramCtrl.dispose();
    _xCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  Future<void> _nextStep() async {
    if (_currentStep == 0) {
      if (_firstNameCtrl.text.trim().isEmpty ||
          _lastNameCtrl.text.trim().isEmpty ||
          _emailCtrl.text.trim().isEmpty ||
          _passCtrl.text.isEmpty ||
          _confirmPassCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa todos los campos requeridos')));
        return;
      }
      if (_passCtrl.text != _confirmPassCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden')));
        return;
      }
      if (!_isPasswordValid) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La contraseña no cumple los requisitos')));
        return;
      }
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Acepta los términos y condiciones')));
        return;
      }
    }
    if (_currentStep == 1) {
      if (_selectedCountry == null || _cityCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona país y ciudad')));
        return;
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      if (_selectedSportIds.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos un deporte')));
        return;
      }

      final socialLinks = <String, String>{
        if (_instagramCtrl.text.trim().isNotEmpty) 'instagram': _instagramCtrl.text.trim(),
        if (_xCtrl.text.trim().isNotEmpty) 'x': _xCtrl.text.trim(),
        if (_websiteCtrl.text.trim().isNotEmpty) 'website': _websiteCtrl.text.trim(),
      };
      
      await ref.read(authControllerProvider.notifier).signUp(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            name: '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}',
            countryId: _selectedCountry!.id,
            city: _cityCtrl.text.trim(),
            sportId: _selectedSportIds.first,
            profileType: _selectedProfileType,
            phone: _phoneCtrl.text.trim(),
            position: _positionCtrl.text.trim(),
            sportLevel: _selectedSportLevel,
            currentTeam: _teamCtrl.text.trim(),
            socialLinks: socialLinks,
            avatarPath: _avatarFile?.path,
          );
      
      if (!mounted) return;
      final auth = ref.read(authControllerProvider);
      if (auth.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error.toString())));
        return;
      }
      if (auth.hasValue && auth.value != null && mounted) Navigator.pop(context);

    }
  }

  bool get _isPasswordValid {
    final pass = _passCtrl.text;
    return pass.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(pass) &&
        RegExp(r'[a-z]').hasMatch(pass) &&
        RegExp(r'[0-9]').hasMatch(pass) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(pass);
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _prevStep,
        ),
        title: Text(
          _currentStep == 0 ? 'Registro de usuario' : 'Configuración inicial',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StepBasicInfo(
                  firstNameCtrl: _firstNameCtrl,
                  lastNameCtrl: _lastNameCtrl,
                  emailCtrl: _emailCtrl,
                  passCtrl: _passCtrl,
                  confirmPassCtrl: _confirmPassCtrl,
                  acceptedTerms: _acceptedTerms,
                  obscurePass: _obscurePass,
                  obscureConfirm: _obscureConfirm,
                  onTermsChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                  onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
                  onToggleConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                _StepContactInfo(
                  onCountrySelected: (c) => setState(() => _selectedCountry = c),
                  selectedCountry: _selectedCountry,
                  phoneCtrl: _phoneCtrl,
                  cityCtrl: _cityCtrl,
                  selectedProfileType: _selectedProfileType,
                  onProfileTypeChanged: (value) => setState(() => _selectedProfileType = value),
                  avatarFile: _avatarFile,
                  onPickAvatar: _pickAvatar,
                ),
                _StepInterests(
                  selectedIds: _selectedSportIds,
                  selectedLevel: _selectedSportLevel,
                  positionCtrl: _positionCtrl,
                  teamCtrl: _teamCtrl,
                  instagramCtrl: _instagramCtrl,
                  xCtrl: _xCtrl,
                  websiteCtrl: _websiteCtrl,
                  onLevelChanged: (value) => setState(() => _selectedSportLevel = value),
                  onToggle: (id) {
                    setState(() {
                      if (_selectedSportIds.contains(id)) {
                        _selectedSportIds.remove(id);
                      } else {
                        _selectedSportIds.add(id);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentStep == 2 ? 'COMPLETAR REGISTRO' : 'CONTINUAR',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBasicInfo extends StatelessWidget {
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmPassCtrl;
  final bool acceptedTerms;
  final bool obscurePass;
  final bool obscureConfirm;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirm;

  const _StepBasicInfo({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmPassCtrl,
    required this.acceptedTerms,
    required this.obscurePass,
    required this.obscureConfirm,
    required this.onTermsChanged,
    required this.onTogglePass,
    required this.onToggleConfirm,
  });

  bool _has(String pattern) => RegExp(pattern).hasMatch(passCtrl.text);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RegField(label: 'Nombres*', controller: firstNameCtrl, hint: 'Ingresar nombres'),
          const SizedBox(height: 14),
          _RegField(label: 'Apellidos*', controller: lastNameCtrl, hint: 'Ingresar apellidos'),
          const SizedBox(height: 14),
          _RegField(label: 'Correo electrónico*', controller: emailCtrl, hint: 'Ingresar correo'),
          const SizedBox(height: 14),
          _RegField(
            label: 'Contraseña*',
            controller: passCtrl,
            hint: 'Ingresar',
            obscure: obscurePass,
            suffix: IconButton(
              onPressed: onTogglePass,
              icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 14),
          _RegField(
            label: 'Confirma tu contraseña*',
            controller: confirmPassCtrl,
            hint: 'Ingresar',
            obscure: obscureConfirm,
            suffix: IconButton(
              onPressed: onToggleConfirm,
              icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _PasswordRule(label: 'Un carácter especial', ok: _has(r'[^A-Za-z0-9]')),
              _PasswordRule(label: 'Al menos un número', ok: _has(r'[0-9]')),
              _PasswordRule(label: 'Al menos 8 caracteres', ok: passCtrl.text.length >= 8),
              _PasswordRule(label: 'Un carácter en mayúscula', ok: _has(r'[A-Z]')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: acceptedTerms,
                onChanged: onTermsChanged,
                activeColor: const Color(0xFF2CB5FF),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'He leído y acepto los Términos y Condiciones de HubSport',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepContactInfo extends ConsumerWidget {
  final Function(Country) onCountrySelected;
  final Country? selectedCountry;
  final TextEditingController phoneCtrl;
  final TextEditingController cityCtrl;
  final String selectedProfileType;
  final ValueChanged<String> onProfileTypeChanged;
  final File? avatarFile;
  final VoidCallback onPickAvatar;

  const _StepContactInfo({
    required this.onCountrySelected,
    required this.selectedCountry,
    required this.phoneCtrl,
    required this.cityCtrl,
    required this.selectedProfileType,
    required this.onProfileTypeChanged,
    required this.avatarFile,
    required this.onPickAvatar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(countriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¡Queremos conocerte!',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Completa tus datos generales. Esto nos ayuda a mostrar oportunidades personalizadas.',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 32),
          const Text('Tipo de perfil *', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _DarkDropdown<String>(
            value: selectedProfileType,
            items: const {
              'athlete': 'Deportista',
              'coach': 'Entrenador',
              'recruiter': 'Reclutador',
              'sponsor': 'Marca / Patrocinador',
              'event_organizer': 'Organizador de eventos',
              'fan': 'Fanático del deporte',
            },
            onChanged: (value) {
              if (value != null) onProfileTypeChanged(value);
            },
          ),
          const SizedBox(height: 24),
          const Text('País *', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          countriesAsync.when(
            data: (list) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Country>(
                  isExpanded: true,
                  value: selectedCountry,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  hint: const Text('Seleccionar país', style: TextStyle(color: Colors.white24)),
                  items: list.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (val) { if (val != null) onCountrySelected(val); },
                ),
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error al cargar países', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 24),
          _RegField(label: 'Ciudad *', controller: cityCtrl, hint: 'Ej. Santo Domingo'),
          const SizedBox(height: 20),
          _RegField(label: 'Teléfono', controller: phoneCtrl, hint: '+34 600 000 000'),
          const SizedBox(height: 24),
          const Text('Foto de perfil', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPickAvatar,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white10,
                    backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null,
                    child: avatarFile == null ? const Icon(Icons.add_a_photo_outlined, color: Colors.white38) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      avatarFile == null ? 'Seleccionar foto de perfil' : 'Foto seleccionada',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepInterests extends ConsumerWidget {
  final List<String> selectedIds;
  final Function(String) onToggle;
  final String? selectedLevel;
  final ValueChanged<String?> onLevelChanged;
  final TextEditingController positionCtrl;
  final TextEditingController teamCtrl;
  final TextEditingController instagramCtrl;
  final TextEditingController xCtrl;
  final TextEditingController websiteCtrl;

  const _StepInterests({
    required this.selectedIds,
    required this.onToggle,
    required this.selectedLevel,
    required this.onLevelChanged,
    required this.positionCtrl,
    required this.teamCtrl,
    required this.instagramCtrl,
    required this.xCtrl,
    required this.websiteCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportsAsync = ref.watch(sportsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus deportes favoritos',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona los deportes que te interesen.',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 32),
          sportsAsync.when(
            data: (list) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: list.map((sport) {
                final isSelected = selectedIds.contains(sport.id);
                return FilterChip(
                  label: Text(sport.name),
                  selected: isSelected,
                  onSelected: (_) => onToggle(sport.id),
                  backgroundColor: Colors.white.withOpacity(0.05),
                  selectedColor: const Color(0xFF3B82F6).withOpacity(0.3),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                  shape: StadiumBorder(side: BorderSide(color: isSelected ? const Color(0xFF3B82F6) : Colors.white10)),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error al cargar deportes', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 20),
          _RegField(label: 'Posición', controller: positionCtrl, hint: 'Ingresar posición'),
          const SizedBox(height: 24),
          const Text('Nivel deportivo', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _DarkDropdown<String>(
            value: selectedLevel,
            hint: 'Seleccionar nivel',
            items: const {
              'beginner': 'Principiante',
              'amateur': 'Amateur',
              'semi_pro': 'Semiprofesional',
              'professional': 'Profesional',
              'elite': 'Élite',
            },
            onChanged: onLevelChanged,
          ),
          const SizedBox(height: 20),
          _RegField(label: 'Equipo actual', controller: teamCtrl, hint: 'Ej. Club Deportivo Central'),
          const SizedBox(height: 20),
          _RegField(label: 'Instagram', controller: instagramCtrl, hint: 'https://instagram.com/usuario'),
          const SizedBox(height: 20),
          _RegField(label: 'X / Twitter', controller: xCtrl, hint: 'https://x.com/usuario'),
          const SizedBox(height: 20),
          _RegField(label: 'Sitio web', controller: websiteCtrl, hint: 'https://tusitio.com'),
        ],
      ),
    );
  }
}

class _RegField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final Widget? suffix;

  const _RegField({
    required this.label,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
          ),
        ),
      ],
    );
  }
}

class _PasswordRule extends StatelessWidget {
  final String label;
  final bool ok;

  const _PasswordRule({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          color: ok ? const Color(0xFF2CE59B) : Colors.white54,
          size: 14,
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}

class _DarkDropdown<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  const _DarkDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          hint: hint == null ? null : Text(hint!, style: const TextStyle(color: Colors.white24)),
          items: items.entries
              .map((entry) => DropdownMenuItem<T>(
                    value: entry.key,
                    child: Text(entry.value),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
