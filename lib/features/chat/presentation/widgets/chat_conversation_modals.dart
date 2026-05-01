import 'package:flutter/material.dart';

/// Azul oscuro de títulos y botón secundario (mockups).
const _kModalNavy = Color(0xFF072353);

LinearGradient get _kPrimaryGradient => const LinearGradient(
      colors: [Color(0xFF4A9EFF), Color(0xFF0D3475)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

Widget _dragHandle() {
  return Container(
    width: 72,
    height: 6,
    margin: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

/// Bottom sheet: eliminar chat / bloquear usuario.
Future<void> showChatConversationActionsSheet(
  BuildContext context, {
  required VoidCallback onDeleteChat,
  required VoidCallback onBlockUser,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dragHandle(),
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  onDeleteChat();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, color: Color(0xFF2D2D2D), size: 30),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Eliminar chat',
                          style: TextStyle(color: Color(0xFF2D2D2D), fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  onBlockUser();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
                  child: Row(
                    children: [
                      const Icon(Icons.person_off_outlined, color: Color(0xFF2D2D2D), size: 30),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Bloquear usuario',
                          style: TextStyle(
                            color: Color(0xFF2D2D2D),
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _dragHandle(),
            ],
          ),
        ),
      );
    },
  );
}

Widget _dialogPillButton({
  required String label,
  required VoidCallback onPressed,
  required bool primary,
}) {
  if (primary) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _kPrimaryGradient,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: _kModalNavy,
      side: const BorderSide(color: _kModalNavy, width: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
    ),
  );
}

/// `true` si el usuario confirmó eliminar.
Future<bool> showDeleteChatConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 38, 32, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿Eliminar este chat?',
                style: TextStyle(
                  color: _kModalNavy,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                'Las personas que te escribieron podrán seguir viendo la conversación '
                'y volver a enviarte mensajes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 20,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 34),
              _dialogPillButton(
                label: 'Eliminar',
                primary: true,
                onPressed: () => Navigator.pop(ctx, true),
              ),
              const SizedBox(height: 12),
              _dialogPillButton(
                label: 'Cancelar',
                primary: false,
                onPressed: () => Navigator.pop(ctx, false),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// `true` si el usuario confirmó bloquear.
Future<bool> showBlockUserConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 38, 32, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿Bloquear este usuario?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _kModalNavy,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Este usuario ya no podrá enviarte mensajes, tampoco podrá ver el contenido '
                'que publiques en tu perfil o grupos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 20,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 34),
              _dialogPillButton(
                label: 'Bloquear',
                primary: true,
                onPressed: () => Navigator.pop(ctx, true),
              ),
              const SizedBox(height: 12),
              _dialogPillButton(
                label: 'Cancelar',
                primary: false,
                onPressed: () => Navigator.pop(ctx, false),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
