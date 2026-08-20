# User (Not Yet Implemented)

## Status
This module is a placeholder — no code exists yet beyond a README describing the intended layout. There is nothing to document in terms of screens, actions, or events at this time.

## Intended Purpose
The README (`lib/modules/user/README.md`) does not describe a specific functional purpose beyond the folder name itself — it only states that this is a placeholder module folder and points to the standard self-contained module layout to follow once implemented. Based on the name and this repo's existing module conventions (compare `lib/features/auth`, which handles login/register/session for the current user), `user` most likely represents a master-data domain for managing user accounts/records within the ERP (as distinct from the authentication flow that establishes a session), but this is inferred from naming alone, not stated in the README.

## Planned Layout
Per the README, this module should follow the architecture guide's self-contained module layout when implemented:

- `models/` — plain Dart classes for user-related data (e.g. a `User` model), with `fromJson`/`toJson` only, no logic.
- `services/` — raw HTTP calls only, made through `ApiService`; no parsing, no state.
- `repository/` — calls the service, unwraps the `{ code, status, message, data: { result, error } }` response envelope via `ResponseModelWrapper`, and throws `AppException` on failure.
- `viewModel/` — a `ChangeNotifier` holding all UI state for the module; screens talk only to this layer.
- `screens/` — a minimal `StatefulWidget` shell.
- `state/` — the screen's `State` class, split out of `screens/` (e.g. `UserScreenState`).
- `widgets/` — widgets private to this module.

As with every module in this repo, the data flow is strict and one-directional: `screens/state → viewModel → repository → service → ApiService`, and no layer may be skipped.

## Next Steps
- Define the `User` model(s) under `models/` (fields/shape depend on the backend contract, not yet specified).
- Add a `UserApiConfig` (or similarly named per-domain config) for this module's endpoint paths, following the pattern of `AccountingApiConfig`.
- Implement `UserService` (raw HTTP via `ApiService`) and `UserRepository` (envelope unwrapping + `AppException` on failure).
- Implement `UserViewModel` extending `ChangeNotifier`.
- Register `UserService` and `UserRepository` as lazy singletons in `lib/network/service_locator.dart`.
- Add a `ChangeNotifierProvider<UserViewModel>` in `main.dart` (`AccountErpApp.build`), scoped appropriately (root `MultiProvider` if app-wide, or locally to the route if only one screen needs it).
- Build `screens/`, `state/`, and `widgets/` for the actual UI.
- Add a named route constant in `lib/routing/app_routes.dart` and wire up navigation.
