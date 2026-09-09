# Auth

## Purpose
Handles user authentication for the Account ERP app: signing in with a username/password, restoring a session on app start, and signing out. It is the gatekeeper that decides whether the user sees the login screen or the dashboard (via `AuthGate`, outside this module).

## Architecture
- **Models** (`models/`): `LoginRequestModel`, `LoginResponseModel`, `UserModel` — plain data classes with `fromJson`/`toJson`, no logic.
- **Service** (`services/auth_service.dart`): `AuthService` — raw HTTP calls via `ApiService` (`login`, `logout`, `fetchProfile`), no parsing.
- **Repository** (`repository/auth_repository.dart`): `AuthRepository` — calls `AuthService`, unwraps the `ResponseModelWrapper` envelope, throws `AppException` on failure, and owns reading/writing the token via `TokenStorage`.
- **ViewModels** (`viewModel/`): `AuthViewModel` (app-wide, provided at the root and consumed by `AuthGate`).
- **Screens** (`screens/`): `LoginScreen` — a minimal `StatefulWidget` shell that just points to its `State` class.
- **State** (`state/`): `LoginScreenState` — holds `TextEditingController`s, `GlobalKey<FormState>`, form validation, and calls into `AuthViewModel`.
- **Widgets** (`widgets/primary_button.dart`): `PrimaryButton` — shared full-width button with a loading spinner state.

Flow: `LoginScreenState` → `AuthViewModel` → `AuthRepository` → `AuthService` → `ApiService`.

## Screens

### LoginScreen (`screens/login_screen.dart`) / LoginScreenState (`state/login_screen_state.dart`)
**Purpose:** Entry screen for signing in to the app.

**UI elements & actions:**
- Username `TextFormField` (`_usernameController`) — autofill hint `AutofillHints.username`; validator requires non-empty (trimmed), else `"Enter your username"`.
- Password `TextFormField` (`_passwordController`) — obscured by default; autofill hint `AutofillHints.password`; validator requires non-empty, else `"Enter your password"`; submitting the keyboard (`onFieldSubmitted`) triggers `_submitSignIn()`.
- Show/hide password `IconButton` (suffix icon) — toggles `_obscurePassword` via `setState`.
- **Sign in** button (`PrimaryButton`) — disabled while `viewModel.isLoading` or the inputs are empty, and disabled with a spinner while loading; calls `_submitSignIn()`.

**Events & state changes:**
- `_submitSignIn()`: unfocuses the keyboard, validates the form, then calls `context.read<AuthViewModel>().login(username, password)`. On failure (`success == false`) it shows the error via `ErrorHandler.showError(context, viewModel.error ?? 'Login failed. Please try again.')`. On success it replaces the route with `AppRoutes.gatewayOfAccounts`.
- `dispose()`: disposes both text controllers.

## ViewModel

### AuthViewModel (`viewModel/auth_view_model.dart`)
App-wide `ChangeNotifier`, provided at the root and read by `AuthGate` and the login screen.

**State (getters):**
- `isCheckingSession` (bool, starts `true`) — session-restore in progress.
- `isLoading` (bool) — login request in progress.
- `isAuthenticated` (bool).
- `error` (String?) — last login error message.
- `user` (UserModel?) — currently signed-in user.

**Methods:**
- `checkAuthStatus()` — called by `AuthGate` on app start. Sets `isCheckingSession = true`, notifies. If no stored token (`repository.hasStoredToken()` is false), clears `_user`/`_isAuthenticated`. Otherwise calls `repository.fetchCurrentUser()`; on success sets `_user` (falling back to the cached `getStoredUser()` if the call returns `null`) and `_isAuthenticated = true`. On `AppException` (profile fetch fails for any reason — invalid token, network error, backend unreachable, etc.), it calls `repository.logout()` and clears `_user`/`_isAuthenticated`, so any failure to confirm the session with the backend sends the user back to the login screen. Always sets `isCheckingSession = false` in `finally` and notifies.
- `login({username, password})` — sets `isLoading = true`, clears `error`, notifies. Calls `repository.login(LoginRequestModel(...))`. On success, sets `_user = session.user`, `_isAuthenticated = true`, returns `true`. On `AppException`, sets `_error = error.message`, returns `false`. On any other exception, sets a generic `'Something went wrong. Please try again.'` and returns `false`. Always sets `isLoading = false` and notifies in `finally`.
- `logout()` — awaits `repository.logout()`, then clears `_user`, `_isAuthenticated`, `_error`, and notifies.

## Repository / Service

### AuthRepository (`repository/auth_repository.dart`)
Constructed with `AuthService` and `TokenStorage`.

- `login(LoginRequestModel request)` → calls `_authService.login(request)`, wraps the JSON in `ResponseModelWrapper<LoginResponseModel>.fromJson(json, fromJson: LoginResponseModel.fromJson)`. If `!wrapper.success` or `result == null`, throws `AppException(wrapper.message ?? 'Login failed. Please try again.', code: wrapper.code)`. On success, stores the token via `_tokenStorage.setToken(session.token)`, fetches the authoritative profile, and returns the `LoginResponseModel`.
- `fetchCurrentUser()` → returns `null` immediately if `!await _tokenStorage.hasToken()` (no session). Otherwise calls `_authService.fetchProfile()`, unwraps as `ResponseModelWrapper<UserModel>`. Throws `AppException(wrapper.message ?? 'Could not load your profile.', code: wrapper.code)` if `!wrapper.success` or result is null. Returns the `UserModel` on success and persists it locally.
- `getStoredUser()` → returns the last profile persisted locally, or `null`.
- `hasStoredToken()` → delegates to `_tokenStorage.hasToken()`.
- `logout()` → clears the locally stored token and user (purely local).

### AuthService (`services/auth_service.dart`)
Constructed with `ApiService`. Pure HTTP, no parsing:
- `login(LoginRequestModel request)` → `POST ApiConfig.loginEndpoint` (`/auth/authenticate`) with `request.toJson()`.
- `logout()` → `POST ApiConfig.logoutEndpoint` (`/auth/logout`), no body.
- `fetchProfile()` → `POST ApiConfig.profileEndpoint` (`/auth/profile`).

Note: `loginEndpoint` is listed in `ApiConfig.publicEndpoints`, so `AuthInterceptor` does not attach a bearer token to that call; `logout` and `fetchProfile` do get the token attached.

## Models

- **LoginRequestModel** (`models/login_request_model.dart`): `username` (String), `password` (String). `toJson()` only (request-only model).
- **LoginResponseModel** (`models/login_response_model.dart`): `token` (String), `user` (UserModel). `fromJson`/`toJson`; defaults `token` to `''` and `user` to an empty-map-derived `UserModel` if missing.
- **UserModel** (`models/user_model.dart`): `id` (String, coerced from any JSON type via string interpolation), `name` (String), `email` (String), `role` (String?, optional). `fromJson`/`toJson` (role omitted from JSON if null).

## Widgets

- **PrimaryButton** (`widgets/primary_button.dart`): stateless, full-width (52px tall) `ElevatedButton` wrapper. Props: `label`, `onPressed`, `loading` (bool, default false — shows a `CircularProgressIndicator` and disables the button instead of the label/icon row), `icon` (optional, shown before the label). Used by the login screen submit button.
