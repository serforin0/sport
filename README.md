# HubSport — App (Flutter)

Cliente móvil de HubSport. Habla con la API REST en `hubsport-api` (Laravel + Sanctum).

## Requisitos

- Flutter SDK compatible con Dart `^3.10.8` (`flutter --version`)
- Android Studio / Xcode según la plataforma que vayas a correr
- Acceso al repo hermano: [hubsport-api](https://github.com/vrincon04/hubsport-api)

## Arranque rápido

```bash
flutter pub get
flutter run
```

Por defecto la app apunta a producción: `https://yordy.shop/api/v1`.

### API local o staging

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=API_FALLBACK_BASE_URL=http://10.0.2.2:8000/api/v1
```

- Emulador Android → `10.0.2.2` es el `localhost` de tu máquina.
- iOS Simulator / dispositivo físico → usa la IP LAN de tu Mac (ej. `http://192.168.x.x:8000/api/v1`).

### Login demo (opcional)

Requiere que el backend tenga `DEMO_LOGIN_ENABLED=true` y el dataset demo sembrado.

```bash
flutter run --dart-define=ENABLE_DEMO_LOGIN=true
```

### APK de prueba (debug) para cliente / QA

```bash
flutter build apk --debug \
  --dart-define=ENABLE_DEMO_LOGIN=true \
  --dart-define=API_BASE_URL=https://yordy.shop/api/v1
```

Salida: `build/app/outputs/flutter-apk/app-debug.apk`  
Incluye el botón **USUARIO DE PRUEBA**. No usar este APK para Play Store.

## Tests y análisis

```bash
flutter test
flutter analyze
```

La suite cubre auth/registro, feed (incl. Mi deporte), chat, jobs, search, notificaciones, shell, scout metrics, safety/reportes, RoleGuide, demo tienda y certificación de fases 6–7.

### E2E (red real)

```bash
./scripts/run_e2e.sh
# o forzar dispositivo:
E2E_DEVICE=<deviceId> ./scripts/run_e2e.sh
```

Suite: `integration_test/hubsport_e2e_suite_test.dart` (login demo, feed/post, tienda, scout, reportes, chat).

CI corre en `.github/workflows/ci.yml` (rama `ultimos-cambios/fixer` / PRs).

## Estructura útil

| Ruta | Contenido |
| ---- | --------- |
| `lib/core/` | Config de API, cliente HTTP, theme |
| `lib/features/` | Módulos (auth, feed, chat, scout_metrics, safety, demo, …) |
| `integration_test/` | E2E contra API demo |
| `test/` | Unit / widget tests |
| `scripts/run_e2e.sh` | Runner E2E (prioriza celular real) |

Estado: **Riverpod**. Identificadores de código en inglés; docs de producto viven fuera de este repo.
