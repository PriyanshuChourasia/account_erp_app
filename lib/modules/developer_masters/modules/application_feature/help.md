# Application Feature

## Purpose
Registry of the application's API features/routes — each entry is an API method + device type + endpoint (e.g. `GET account_natures` for web/mobile), used for API-level permission/registry configuration. Not linked to `application_module` — the two are independent masters.

## Architecture
Full layered implementation, mirroring `accounting_masters/modules/account_nature`:

- `models/application_feature.dart` — `ApplicationFeature` (read model, includes UI-only `icon`/`color` and `demo` fallback data), plus the `ApiMethod` and `ApiDeviceType` enums mirroring the backend's Java enums (`ApiDeviceType` confirmed against the real `APIDeviceType` enum: `ALL, MOBILE, DESKTOP, WEB`; `ApiMethod` is a best guess at standard REST verbs — confirm against the backend `ApiMethod` enum before relying on it).
- `models/create_application_feature_request.dart` — `CreateApplicationFeatureRequest`, mirrors `CreateApplicationFeatureDTO` (`name`, `apiMethod`, `apiDeviceType`, `endPoint`, `description`, `active`).
- `services/application_feature_service.dart` — `ApplicationFeatureService`, raw HTTP via `ApiService` and `DeveloperApiConfig`.
- `repository/application_feature_repository.dart` — `ApplicationFeatureRepository`, unwraps `ResponseModelWrapper` and throws `AppException`.
- `viewModel/application_feature_view_model.dart` — `ApplicationFeatureViewModel` (`ChangeNotifier`).
- `screens/application_feature_screen.dart` — `ApplicationFeatureScreen` (StatefulWidget shell).
- `state/application_feature_screen_state.dart` — `ApplicationFeatureScreenState` (search, list/table, add, delete).
- `widgets/application_feature_card.dart` — `ApplicationFeatureCard` (mobile list row).
- `widgets/application_feature_add_dialog.dart` — `ApplicationFeatureAddDialog` (create form with method/device-type dropdowns and an active toggle).

Create-only (no update yet) — matches `account_nature`, not the fuller `account_group` CRUD. `id` is a backend-assigned UUID (`String` in Dart), not an int.
