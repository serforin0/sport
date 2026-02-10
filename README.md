# HubSport (Flutter)

Proyecto móvil en **Flutter** con una pantalla de autenticación moderna que incluye **landing + login en una sola página**, fondo en **video MP4**, transiciones y tests de widgets.

---

## ✅ Lo que incluye actualmente

- Pantalla `AuthPage` con dos modos:
  - **Landing** (registro + social)
  - **Login** (correo/contraseña + social)
- Fondo con **video MP4** usando `VideoBackground`
- Transiciones suaves con `AnimatedSwitcher` (fade + slide)
- UI responsive: scroll + evita overflow en pantallas pequeñas
- Inyección de fondo por parámetro (`background`) para facilitar pruebas
- Tests de widgets para el flujo principal

---

## 🧪 Tests

Ejecutar:
```bash
flutter test
