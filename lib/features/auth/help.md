# Auth

## Purpose
Handles user authentication for the Account ERP app: signing in with a username/password, creating a new account, restoring a session on app start, and signing out. It is the gatekeeper that decides whether the user sees the login/register flow or the dashboard (via `AuthGate`, outside this module).

## Architecture
- **Models** (`models/`): `LoginRequestModel`, `LoginResponseModel`, `RegisterRequestModel`, `UserModel` — plain data classes with `fromJson`/`toJson`, no logic.
- **Service** (`services/auth_service.dart`): `AuthService` — raw HTTP calls via `ApiService` (`login`, `register`, `logout`, `fetchProfile`), no parsing.
- **Repository** (`repository/auth_repository.dart`): `AuthRepository` — calls `AuthService`, unwraps the `ResponseModelWrapper` envelope, throws `AppException` on failure, and owns reading/writing the token via `TokenStorage`.
- **ViewModels** (`viewModel/`): `AuthViewModel` (app-wide, provided at the root and consumed by `AuthGate`) and `RegisterViewModel` (scoped locally to `RegisterScreen` only).
- **Screens** (`screens/`): `LoginScreen`, `RegisterScreen` — minimal `StatefulWidget` shells that just point to their `State` classes.
- **State** (`state/`): `LoginScreenState`, `RegisterScreenState` — hold `TextEditingController`s, `GlobalKey<FormState>`, form validation, and call into the view models.
- **Widgets** (`widgets/primary_button.dart`): `PrimaryButton` — shared full-width button with a loading spinner state, used by both screens.

Flow: `LoginScreenState`/`RegisterScreenState` → `AuthViewModel`/`RegisterViewModel` → `AuthRepository` → `AuthService` → `ApiService`.

## Screens

### LoginScreen (`screens/login_screen.dart`) / LoginScreenState (`state/login_screen_state.dart`)
**Purpose:** Entry screen for signing in to the app.

**UI elements & actions:**
- Username `TextFormField` (`_usernameController`) — autofill hint `AutofillHints.username`; validator requires non-empty (trimmed), else `"Enter your username or email"`.
- Password `TextFormField` (`_passwordController`) — obscured by default; autofill hint `AutofillHints.password`; validator requires non-empty, else `"Enter your password"`; submitting the keyboard (`onFieldSubmitted`) triggers `_submit()`.
- Show/hide password `IconButton` (suffix icon) — toggles `_obscurePassword` via `setState`.
- **Sign in** button (`PrimaryButton`) — disabled while `viewModel.isLoading`; shows a spinner while loading; calls `_submit()`.
- "Create one" `TextButton` — calls `_openRegister()`, which does `Navigator.pushNamed(AppRoutes.register)` and awaits a result.

**Events & state changes:**
- `_submit()`: unfocuses the keyboard, validates the form, then calls `context.read<AuthViewModel>().login(username, password)`. On failure (`success == false`) it shows the error via `ErrorHandler.showError(context, viewModel.error ?? 'Login failed. Please try again.')`. On success it does nothing itself — `AuthGate` (outside this module) watches `AuthViewModel.isAuthenticated` and swaps to `DashboardScreen` automatically.
- `_openRegister()`: pushes `RegisterScreen`; if it pops with a `String` (the newly registered username), prefills `_usernameController` and shows a snackbar via `ErrorHandler.showMessage(context, 'Account created — sign in to continue.')`.
- `dispose()`: disposes both text controllers.
- No `initState` logic beyond field declarations; the screen `watch`es `AuthViewModel` for `isLoading` to drive the button state.

### RegisterScreen (`screens/register_screen.dart`) / RegisterScreenState (`state/register_screen_state.dart`)
**Purpose:** Screen for creating a new account; pushed from the login screen.

**UI elements & actions:**
- Back `IconButton` (top-left) — `Navigator.pop(context)`.
- Full name `TextFormField` (`_nameController`) — autofill `AutofillHints.name`; validator requires non-empty (trimmed), else `"Enter your full name"`.
- Email `TextFormField` (`_emailController`) — keyboard type email, autofill `AutofillHints.email`; validated by `_validateEmail`: requires non-empty, and must match regex `^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$`, else `"Enter a valid email address"`.
- Username `TextFormField` (`_usernameController`) — autofill `AutofillHints.username`; validator requires non-empty and at least 3 characters (trimmed), else `"Choose a username"` / `"Username must be at least 3 characters"`.
- Password `TextFormField` (`_passwordController`) — obscured by default, autofill `AutofillHints.newPassword`; validator requires non-empty and at least 6 characters, else `"Choose a password"` / `"Password must be at least 6 characters"`; submitting the keyboard triggers `_submit()`.
- Show/hide password `IconButton` (suffix icon) — toggles `_obscurePassword` via `setState`.
- **Sign up** button (`PrimaryButton`) — disabled while `viewModel.isLoading`; shows spinner while loading; calls `_submit()`.
- "Sign in" `TextButton` — pops back to the login screen (no data).

**Events & state changes:**
- `_submit()`: unfocuses keyboard, validates form, calls `context.read<RegisterViewModel>().register(name, email, username, password)`. On failure shows `ErrorHandler.showError(context, viewModel.error ?? 'Registration failed. Please try again.')` and returns. On success, pops the screen with the trimmed username as the return value (`Navigator.pop(_usernameController.text.trim())`) so `LoginScreenState` can prefill it.
- `dispose()`: disposes all four text controllers.
- `RegisterViewModel` is provided locally (scoped to this route only), not app-wide.

## ViewModel(s)

### AuthViewModel (`viewModel/auth_view_model.dart`)
App-wide `ChangeNotifier`, provided at the root and read by `AuthGate` and both auth screens.

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

### RegisterViewModel (`viewModel/register_view_model.dart`)
Scoped locally to `RegisterScreen` (not app-wide).

**State (getters):** `isLoading` (bool), `error` (String?).

**Methods:**
- `register({name, email, username, password})` — sets `isLoading = true`, clears `error`, notifies. Calls `repository.register(RegisterRequestModel(...))`. Returns `true` on success. On `AppException`, sets `_error = error.message` and returns `false`. On any other exception, sets a generic error message and returns `false`. Always resets `isLoading` and notifies in `finally`.

## Repository / Service

### AuthRepository (`repository/auth_repository.dart`)
Constructed with `AuthService` and `TokenStorage`.

- `login(LoginRequestModel request)` → calls `_authService.login(request)`, wraps the JSON in `ResponseModelWrapper<LoginResponseModel>.fromJson(json, fromJson: LoginResponseModel.fromJson)`. If `!wrapper.success` or `result == null`, throws `AppException(wrapper.message ?? 'Login failed. Please try again.', code: wrapper.code)`. On success, stores the token via `_tokenStorage.setToken(session.token)` and returns the `LoginResponseModel`.
- `register(RegisterRequestModel request)` → calls `_authService.register(request)`, wraps as `ResponseModelWrapper<dynamic>` (no result converter — the envelope carries no meaningful `result` payload for registration, only `success` matters). Throws `AppException(wrapper.message ?? 'Registration failed. Please try again.', code: wrapper.code)` if `!wrapper.success`. Returns `void` on success (the caller then logs in separately).
- `fetchCurrentUser()` → returns `null` immediately if `!await _tokenStorage.hasToken()` (no session). Otherwise calls `_authService.fetchProfile()`, unwraps as `ResponseModelWrapper<UserModel>`. Throws `AppException(wrapper.message ?? 'Could not load your profile.', code: wrapper.code)` if `!wrapper.success` or result is null. Returns the `UserModel` on success.
- `hasStoredToken()` → delegates to `_tokenStorage.hasToken()`.
- `logout()` → calls `_authService.logout()`; if it throws `AppException`, the error is swallowed (best-effort — comment: "clear the local session regardless of server response"). In `finally`, always calls `_tokenStorage.clearToken()`.

### AuthService (`services/auth_service.dart`)
Constructed with `ApiService`. Pure HTTP, no parsing:
- `login(LoginRequestModel request)` → `POST ApiConfig.loginEndpoint` (`/auth/login`) with `request.toJson()`.
- `register(RegisterRequestModel request)` → `POST ApiConfig.registerEndpoint` (`/auth/register`) with `request.toJson()`.
- `logout()` → `POST ApiConfig.logoutEndpoint` (`/auth/logout`), no body.
- `fetchProfile()` → `POST ApiConfig.profileEndpoint` (`/auth/profile`).

Note: `loginEndpoint` and `registerEndpoint` are listed in `ApiConfig.publicEndpoints`, so `AuthInterceptor` does not attach a bearer token to those two calls; `logout` and `fetchProfile` do get the token attached.

## Models

- **LoginRequestModel** (`models/login_request_model.dart`): `username` (String), `password` (String). `toJson()` only (request-only model).
- **LoginResponseModel** (`models/login_response_model.dart`): `token` (String), `user` (UserModel). `fromJson`/`toJson`; defaults `token` to `''` and `user` to an empty-map-derived `UserModel` if missing.
- **RegisterRequestModel** (`models/register_request_model.dart`): `name`, `email`, `username`, `password` (all String). `toJson()` only.
- **UserModel** (`models/user_model.dart`): `id` (String, coerced from any JSON type via string interpolation), `name` (String), `email` (String), `role` (String?, optional). `fromJson`/`toJson` (role omitted from JSON if null).

## Widgets

- **PrimaryButton** (`widgets/primary_button.dart`): stateless, full-width (52px tall) `ElevatedButton` wrapper. Props: `label`, `onPressed`, `loading` (bool, default false — shows a `CircularProgressIndicator` and disables the button instead of the label/icon row), `icon` (optional, shown before the label). Shared by both `LoginScreenState` and `RegisterScreenState` for their submit buttons.
