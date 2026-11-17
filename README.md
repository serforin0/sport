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

## Tests y análisis

```bash
flutter test
# Flujos MVP (auth, conexiones, chat, jobs, feed, demo):
flutter test test/features/auth/domain test/features/connections/domain test/features/chat/domain test/features/jobs/domain test/features/feed/domain test/features/demo
flutter analyze
```

CI corre en `.github/workflows/ci.yml` (rama `ultimos-cambios/fixer` / PRs).

## Estructura útil

| Ruta | Contenido |
| ---- | --------- |
| `lib/core/` | Config de API, cliente HTTP |
| `lib/features/` | Módulos (auth, feed, chat, demo, …) |
| `test/` | Unit / widget tests |

Estado: **Riverpod**. Identificadores de código en inglés; docs de producto viven fuera de este repo.
