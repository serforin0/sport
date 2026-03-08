import 'package:flutter_test/flutter_test.dart';
import 'package:sport/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateName handles empty and short names', () {
      expect(Validators.validateName(''), 'Este campo no puede estar vacío');
      expect(Validators.validateName('A'), 'Debe tener al menos 2 caracteres');
      expect(Validators.validateName('Miguel'), isNull);
    });

    test('validateEmail handles invalid formats', () {
      expect(Validators.validateEmail('invalid-email'), 'Ingrese un correo válido');
      expect(Validators.validateEmail('test@domain'), 'Ingrese un correo válido');
      expect(Validators.validateEmail('test@domain.com'), isNull);
    });

    test('validateMessage handles short messages', () {
      expect(Validators.validateMessage(''), 'El mensaje no puede estar vacío');
      expect(Validators.validateMessage('Short'), 'El mensaje debe ser más detallado (mín. 10 caracteres)');
      expect(Validators.validateMessage('This is a long enough message.'), isNull);
    });
  });
}
