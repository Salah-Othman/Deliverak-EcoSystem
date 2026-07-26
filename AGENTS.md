# Deliverak — Agent Guide

## Project State

Early-stage Flutter monorepo. **Customer app** is the only app with real code. Driver, vendor, and admin are default Flutter scaffolds (not yet implemented).

## Monorepo Structure

Melos manages 4 apps + 6 shared packages:

```
apps/
  customer/    ← Only app with Deliverak code
  driver/      ← Scaffold (default counter app)
  vendor/      ← Scaffold (default counter app)
  admin/       ← Scaffold (default counter app)

packages/
  core/              ← Models, enums, interfaces, utils, exceptions (no implementations)
  firebase_services/ ← Implements IAuthService, IFirestoreService, INotificationService from core
  cloudinary_service/← Implements IStorageService from core
  repositories/      ← Implements I*Repository interfaces from core
  providers/         ← Cubits (depend on core interfaces only)
  ui_kit/            ← Design tokens, theme, reusable widgets
```

## Dependency Chain

```
core ← firebase_services, cloudinary_service, repositories, providers
repositories ← core
providers ← core
ui_kit ← (standalone, only shimmer)
apps ← all packages
```

**Rule:** `core` has zero internal package dependencies. It depends only on Firebase SDKs. All other packages depend on `core` for interfaces/models.

## Commands

```bash
melos bootstrap              # Install all dependencies
melos run analyze            # dart analyze --fatal-infos on all packages
melos run test               # flutter test on all packages
melos run format             # dart format --set-exit-if-changed .
melos run customer:android   # Run customer app
melos run admin:web          # Run admin panel
```

Run from repo root. No CI workflows exist yet.

## Architecture Conventions

- **SOLID + DIP:** Cubits depend on repository interfaces (`IAuthRepository`), never concrete classes. Repositories depend on service interfaces (`IAuthService`).
- **Barrel files:** Every package exports through a single `lib/<package>.dart` barrel. Import via `package:<package>/<package>.dart`.
- **Cubit pattern:** State classes extend `Equatable`. States: `Initial`, `Loading`, `Loaded`, `Error` (with `message`, `code`, `isRetryable`).
- **Models:** Use `Equatable`, implement `fromMap`/`toMap`/`copyWith`.
- **Env vars:** Use `String.fromEnvironment` in `lib/config/env.dart` per app (see `apps/customer/lib/config/env.dart`).
- **Composition root:** `main.dart` creates service instances, wires repository/provider providers via `MultiRepositoryProvider` + `MultiBlocProvider`.

## Key Files

- `plan.md` — Full architecture spec, Firestore schema, security rules, SOLID examples
- `packages/core/lib/core.dart` — All exported interfaces and models
- `apps/customer/lib/main.dart` — Working composition root example
- `packages/providers/lib/src/auth_cubit.dart` — Reference Cubit implementation

## Gotchas

- `driver/` and `vendor/` apps are unmodified Flutter templates — do not reference their code as examples.
- `core` package depends on `firebase_auth`, `cloud_firestore`, `firebase_messaging` directly (interfaces reference Firebase types like `User`, `PhoneAuthCredential`).
- No `opencode.json`, no CI, no test infrastructure beyond default `flutter_test`.
- Analysis uses `flutter_lints` (not `very_good_analysis` or custom rules).
