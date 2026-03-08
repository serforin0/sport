import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _firstNameController = TextEditingController(text: 'Lewis');
  final _lastNameController = TextEditingController(text: 'Hamilton');
  final _birthDateController = TextEditingController(text: '07/01/1985');
  final _profileTypeController = TextEditingController(text: 'Deportista');
  final _sportController = TextEditingController(text: 'Automovilismo');
  final _positionController = TextEditingController(text: 'Piloto');
  final _bioController = TextEditingController(
      text: '7-time Formula 1 World Champion. Driven by precision, speed, and a passion for change.');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _profileTypeController.dispose();
    _sportController.dispose();
    _positionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'EDITAR PERFIL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Guardar cambios
              Navigator.pop(context);
            },
            child: const Text(
              'GUARDAR',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white10,
                    backgroundImage: kDebugMode && !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST') 
                      ? null 
                      : const NetworkImage('https://img.vavel.com/l-hamilton-6668.jpg'),
                    child: kDebugMode && !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST') 
                      ? const Icon(Icons.person, color: Colors.white24, size: 40)
                      : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _EditField(
              key: const Key('first_name_field'),
              label: 'Nombres',
              controller: _firstNameController,
            ),
            const SizedBox(height: 24),
            _EditField(
              key: const Key('last_name_field'),
              label: 'Apellidos',
              controller: _lastNameController,
            ),
            const SizedBox(height: 24),
            _EditField(
              key: const Key('birth_date_field'),
              label: 'Fecha de nacimiento',
              controller: _birthDateController,
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.white24, size: 18),
            ),
            const SizedBox(height: 24),
            _EditField(
              key: const Key('profile_type_field'),
              label: 'Tipo de perfil',
              controller: _profileTypeController,
              suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
            ),
            const SizedBox(height: 24),
            _EditField(
              key: const Key('sport_field'),
              label: 'Deporte',
              controller: _sportController,
              suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
            ),
            const SizedBox(height: 24),
            _EditField(
              key: const Key('position_field'),
              label: 'Posición',
              controller: _positionController,
              hintText: 'Ingresar posición',
            ),
            const SizedBox(height: 24),
            _EditField(
              key: const Key('bio_field'),
              label: 'BIOGRAFÍA',
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            _EditField(
              label: 'UBICACIÓN',
              hintText: 'Ej. Stevenage, Reino Unido',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final int maxLines;
  final Widget? suffixIcon;

  const _EditField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3B82F6),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
        ),
      ],
    );
  }
}
