# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                     # install dependencies
flutter run                         # run the app (defaults to a connected device/emulator)
flutter analyze                     # static analysis (flutter_lints, see analysis_options.yaml)
flutter test                        # run all tests
flutter test test/widget_test.dart  # run a single test file
flutter test --plain-name "shows the login screen when no session is stored"  # run a single test by name
```

The backend is expected at `http://127.0.0.1:8060/api` (`http://10.0.2.2:8060/api` on the Android emulator) — see `lib/config/api_config.dart`. No backend is bundled in this repo; without it reachable, network calls fail and screens surface the resulting error through the normal error-handling path (this is exercised by the register-flow test).

## Architecture

This is a Flutter app (Provider for state, GetIt for DI, Dio for HTTP) organized as **self-contained modules**, each following the same internal layout:

```
<module>/
  models/       plain Dart classes, `fromJson`/`toJson`, no logic
  services/     raw HTTP calls only (via ApiService) — no parsing, no state
  repository/   calls the service, unwraps the response envelope, throws AppException on failure
  viewModel/    ChangeNotifier holding all UI state; screens only ever talk to this
  screens/      StatefulWidget shell (kept minimal)
  state/        the StatefulWidget's State class, split out of screens/ (`<Screen>State`)
  widgets/      widgets private to the module
```

This layering is strict and one-directional: **screens/state → viewModel → repository → service → ApiService**. Never skip a layer (e.g. a screen calling a repository or service directly).

### Two top-level trees: `features/` vs `modules/`

- `lib/features/` — flat feature areas that don't nest further sub-domains: `auth`, `dashboard`.
- `lib/modules/` — business/master-data domains, most of which nest further sub-modules under a `modules/` folder of their own, e.g. `modules/accounting_masters/modules/account_nature/`, `modules/inventory_masters/modules/stock_group/`. A domain's own `screens/`, `widgets/`, `utils/` hold things shared across its sub-modules (e.g. an index screen listing the masters as cards, a shared `MasterCard` widget). `modules/items/` is an exception: it's a single module with no further nesting.

Current domains: `accounting_masters` (account_nature, account_group; more masters planned: ledger, party, unit, tax), `inventory_masters` (stock_group, stock_category, unit; planned: item, location), `organisational_masters` (country, state), `items`. Several directories (`modules/user/`, `modules/application_module/`, `modules/application_feature/`) are placeholders for future modules — each has a `README.md` describing the intended layout; check for one before assuming a folder is unused.

When adding a new master/module, copy this layout rather than inventing a new one — most directories have a local `README.md` documenting what belongs there.

### Networking and error handling

- `ApiService` (`lib/network/api_service.dart`) is the only class that talks to Dio directly. It does no parsing — it returns the decoded JSON body or throws `AppException`.
- `DioClient` (`lib/network/dio_client.dart`) builds the shared `Dio` instance (base URL, timeouts, interceptors). `AuthInterceptor` attaches the bearer token from `TokenStorage` to every request except `ApiConfig.publicEndpoints`. `ErrorInterceptor` normalizes every `DioException` into an `AppException` before it reaches `ApiService`.
- Every backend response is wrapped in a `{ code, status, message, data: { result, error } }` envelope, parsed by `ResponseModelWrapper` (`lib/data/models/response_model_wrapper.dart`). **Repositories are responsible for unwrapping this envelope** and throwing `AppException` on `!wrapper.success` — services must never do this.
- `AppException` (`lib/core/app_exception.dart`) is the only exception type that should ever reach a viewModel or screen. ViewModels catch it and expose `error`/`isLoading` getters; screens render it via `ErrorHandler.showError`/`showMessage` (`lib/core/handlers/error_handler.dart`) rather than calling `ScaffoldMessenger` directly.

### Dependency injection and state ownership

- `lib/network/service_locator.dart` registers every singleton (`TokenStorage`, interceptors, `DioClient`, `ApiService`, each `*Service`, each `*Repository`) with GetIt via `registerLazySingleton`. Resolve dependencies with `globalService<T>()` — never touch `GetIt.instance` directly. `initServiceLocator()` is called once from `main()` before `runApp()`, and again in test `setUpAll` (it's idempotent).
- **ViewModels are intentionally NOT registered in GetIt.** They're created by `ChangeNotifierProvider`s in `main.dart` (`AccountErpApp.build`) so their lifetime matches the widget tree. App-wide viewModels go in the root `MultiProvider`; a viewModel only one screen needs (e.g. `RegisterViewModel`) is scoped locally to that route instead.
- Adding a new module means: register its `Service`+`Repository` in `service_locator.dart`, then add a `ChangeNotifierProvider<XViewModel>` in `main.dart`.

### Config

- `lib/config/api_config.dart` — base URL (platform-aware for the Android emulator), timeouts, endpoint paths, `publicEndpoints`, storage keys. Each domain module additionally has its own `configs/<domain>_api_config.dart` (e.g. `AccountingApiConfig`) for its endpoints, rather than growing the global `ApiConfig`.
- `lib/routing/app_routes.dart` — central named-route constants; never hardcode route strings.
- `lib/config/theme/app_theme.dart` — `AppColors` and the single `AppTheme.light` `ThemeData`; keep visual styling here rather than inline in widgets.
- `AuthGate` (`lib/config/auth_gate.dart`) decides login vs. dashboard based on `AuthViewModel`, but note `main.dart` currently sets `home: const DashboardScreen()` directly rather than using it.
