import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:sport/features/settings/presentation/providers/profile_providers.dart';
import 'package:sport/features/settings/domain/repositories/settings_repository.dart';
import 'package:sport/core/result/result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/test_utils.dart';

void main() {
  late MockSettingsRepository mockSettingsRepository;

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    
    // Default mock response
    when(() => mockSettingsRepository.getProfile())
        .thenAnswer((_) async => const Ok(tUserProfile));
    when(() => mockSettingsRepository.updateProfile(any()))
        .thenAnswer((_) async => const Ok(null));
  });

  // Required for mocktail with custom types
  setUpAll(() {
    registerFallbackValue(tUserProfile);
  });

  testWidgets('EditProfilePage renders all fields and buttons', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(
      createTestableWidget(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(mockSettingsRepository),
        ],
        child: const MaterialApp(home: EditProfilePage()),
      ),
    );

    // Wait for data to load
    await tester.pump();

    // Verify title
    expect(find.text('EDITAR PERFIL'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);

    // Verify fields by labels
    expect(find.text('Nombres'), findsOneWidget);
    expect(find.text('Apellidos'), findsOneWidget);
    
    // Verify values from mock
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);
  });

  testWidgets('EditProfilePage validation and text entry', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(
      createTestableWidget(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(mockSettingsRepository),
        ],
        child: const MaterialApp(home: EditProfilePage()),
      ),
    );

    await tester.pump();

    // Find first name field by its label ancestor
    final firstNameTextField = find.descendant(
      of: find.byKey(const Key('first_name_field')),
      matching: find.byType(TextFormField),
    );
    
    // Test text entry
    await tester.enterText(firstNameTextField, 'Updated Name');
    await tester.pump();
    expect(find.text('Updated Name'), findsOneWidget);
    
    final saveButton = find.text('Guardar');
    await tester.ensureVisible(saveButton);

    // Test validation: Empty
    await tester.enterText(firstNameTextField, '');
    await tester.tap(saveButton);
    await tester.pump();
    expect(find.text('Este campo no puede estar vacío'), findsOneWidget);
    
    // Test validation: Short
    await tester.enterText(firstNameTextField, 'A');
    await tester.tap(saveButton);
    await tester.pump();
    expect(find.text('Debe tener al menos 2 caracteres'), findsOneWidget);
  });
}
