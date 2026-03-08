import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import 'package:sport/features/settings/domain/entities/user_profile.dart';
import 'package:sport/features/settings/presentation/providers/profile_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _birthDateController;
  late TextEditingController _profileTypeController;
  late TextEditingController _sportController;
  late TextEditingController _positionController;
  late TextEditingController _bioController;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _birthDateController = TextEditingController();
    _profileTypeController = TextEditingController();
    _sportController = TextEditingController();
    _positionController = TextEditingController();
    _bioController = TextEditingController();
  }

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

  void _updateControllers(UserProfile profile) {
    if (!_initialized) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _birthDateController.text = profile.birthDate;
      _profileTypeController.text = profile.profileType;
      _sportController.text = profile.sport;
      _positionController.text = profile.position;
      _bioController.text = profile.bio;
      _initialized = true;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = UserProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        birthDate: _birthDateController.text,
        profileType: _profileTypeController.text,
        sport: _sportController.text,
        position: _positionController.text,
        bio: _bioController.text,
      );

      await ref.read(profileControllerProvider(null).notifier).updateProfile(updatedProfile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado con éxito')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider(null));

    // Update controllers once data is available
    profileAsync.whenData(_updateControllers);

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
      ),
      body: profileAsync.when(
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
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
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 24),
                _EditField(
                  key: const Key('last_name_field'),
                  label: 'Apellidos',
                  controller: _lastNameController,
                  validator: Validators.validateName,
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
                    onPressed: profileAsync.isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: profileAsync.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
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
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
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
  final String? Function(String?)? validator;

  const _EditField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.maxLines = 1,
    this.suffixIcon,
    this.validator,
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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
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
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
