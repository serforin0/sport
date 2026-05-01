import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_dropdown_field.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/profile_avatar_picker.dart';
import 'search_selection_page.dart';
import '../providers/auth_providers.dart';
import '../providers/meta_providers.dart';
import 'package:sport/features/auth/domain/entities/meta.dart';


class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  String? _selectedProfileType;
  Sport? _selectedSport;
  Country? _selectedCountry;
  final TextEditingController _positionController = TextEditingController();

  final List<String> _profileTypes = ['Deportista', 'Entrenador', 'Reclutador'];

  Future<void> _handleSave() async {
    final auth = ref.read(authControllerProvider);
    if (!auth.hasValue || auth.value == null) return;

    final nameParts = auth.value!.name?.split(' ') ?? [];
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    await ref.read(authControllerProvider.notifier).updateProfile(
          firstName: firstName,
          lastName: lastName,
          sportId: _selectedSport?.id,
          countryId: _selectedCountry?.id,
          bio: _positionController.text, // Reusing position field as bio/position
        );

    if (mounted) {
      final newState = ref.read(authControllerProvider);
      if (!newState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(newState.error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);
    final sportsAsync = ref.watch(sportsProvider);
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Completar Perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¡Queremos conocerte!',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Completa los datos generales de tu perfil para acceder a oportunidades personalizadas.',
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              Center(
                child: ProfileAvatarPicker(onTap: () {}),
              ),
              const SizedBox(height: 32),
              const Text('País *', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              countriesAsync.when(
                data: (list) => CustomDropdownField<Country>(
                  hintText: 'Seleccionar país',
                  value: _selectedCountry,
                  items: list.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() => _selectedCountry = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error al cargar países', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 24),
              const Text('Deporte *', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              sportsAsync.when(
                data: (list) => CustomDropdownField<Sport>(
                  hintText: 'Seleccionar deporte',
                  value: _selectedSport,
                  items: list.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: (val) => setState(() => _selectedSport = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error al cargar deportes', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 24),
              const Text('Posición / Bio', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'Ej. Delantero central',
                controller: _positionController,
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: isLoading ? 'Guardando...' : 'GUARDAR Y CONTINUAR',
                onPressed: () { _handleSave(); },
                isLoading: isLoading,
              ),



              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
