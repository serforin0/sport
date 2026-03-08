class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo no puede estar vacío';
    }
    if (value.length < 2) {
      return 'Debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  static String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'El mensaje no puede estar vacío';
    }
    if (value.length < 10) {
      return 'El mensaje debe ser más detallado (mín. 10 caracteres)';
    }
    return null;
  }
}
