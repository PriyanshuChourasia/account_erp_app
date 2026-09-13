# Application Module

## Purpose
Registry of the ERP's own modules (e.g. `Accounting Masters`, `Inventory Masters`). Independent of `application_feature` — the two masters are not linked.

## Architecture
Full layered implementation, mirroring `accounting_masters/modules/account_nature`:

- `models/application_module.dart` — `ApplicationModule` (read model, includes UI-only `icon`/`color` and `demo` fallback data). Mirrors `ApplicationModuleDTO`: `id` (UUID), `name`, `code` (`String`, backend-assigned), `description`, `endpoint`, `isSystem`, `version`, `active`.
- `models/create_application_module_request.dart` — `CreateApplicationModuleRequest`, mirrors `CreateApplicationModuleDTO` (`name`, `description`, `endpoint`, `isSystem` — no `code`/`version`/`active`, which are backend-assigned/defaulted).
- `services/application_module_service.dart` — `ApplicationModuleService`, raw HTTP via `ApiService` and `DeveloperApiConfig`.
- `repository/application_module_repository.dart` — `ApplicationModuleRepository`, unwraps `ResponseModelWrapper` and throws `AppException`.
- `viewModel/application_module_view_model.dart` — `ApplicationModuleViewModel` (`ChangeNotifier`).
- `screens/application_module_screen.dart` — `ApplicationModuleScreen` (StatefulWidget shell).
- `state/application_module_screen_state.dart` — `ApplicationModuleScreenState` (search, list/table with a delete action column, add, delete).
- `widgets/application_module_card.dart` — `ApplicationModuleCard` (mobile list row, with Active/Inactive and System status pills).
- `widgets/application_module_add_dialog.dart` — `ApplicationModuleAddDialog` (create form with a "System module" toggle).

Create-only (no update yet) — matches `account_nature`, not the fuller `account_group` CRUD. `id` is a backend-assigned UUID (`String` in Dart), not an int.
