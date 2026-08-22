import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'api_config.dart';

/// Persists the auth token (and other session data) locally as a JSON file
/// under the platform's application-support directory, so the session
/// survives app restarts/reloads.
///
/// An optional [directory] can be injected for testing; otherwise it is
/// resolved lazily via [getApplicationSupportDirectory].
class TokenStorage {
  TokenStorage({Directory? directory})
    : _directory = directory,
      _memoryStore = null;

  /// In-memory variant with no real file I/O, for widget tests: real
  /// `dart:io` futures don't reliably resolve under the fake clock that
  /// `flutter_test` pumps, which can hang [WidgetTester.pumpAndSettle].
  TokenStorage.inMemory([Map<String, String>? seed])
    : _directory = null,
      _memoryStore = Map<String, String>.of(seed ?? {});

  static const String _fileName = 'account_local_key_store.json';

  Directory? _directory;
  final Map<String, String>? _memoryStore;
  Map<String, String>? _cache;

  Future<Directory> get _dir async =>
      _directory ??= await getApplicationSupportDirectory();

  Future<File> get _file async {
    final dir = await _dir;
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, String>> _read() async {
    final memoryStore = _memoryStore;
    if (memoryStore != null) return memoryStore;
    final cached = _cache;
    if (cached != null) return cached;
    final file = await _file;
    if (!await file.exists()) return _cache = {};
    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return _cache = {};
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      return _cache = decoded.map(
        (key, value) => MapEntry(key, value as String),
      );
    } catch (_) {
      return _cache = {};
    }
  }

  Future<void> _write(Map<String, String> data) async {
    final memoryStore = _memoryStore;
    if (memoryStore != null) {
      memoryStore
        ..clear()
        ..addAll(data);
      return;
    }
    _cache = data;
    final file = await _file;
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(data));
  }

  Future<String?> getToken() async => (await _read())[ApiConfig.tokenKey];

  Future<void> setToken(String token) async {
    final data = Map<String, String>.of(await _read());
    data[ApiConfig.tokenKey] = token;
    await _write(data);
  }

  Future<void> clearToken() async {
    final data = Map<String, String>.of(await _read());
    data.remove(ApiConfig.tokenKey);
    await _write(data);
  }

  Future<bool> hasToken() async => (await getToken())?.isNotEmpty ?? false;

  /// Persists the signed-in user's profile as a raw JSON string. Kept
  /// feature-agnostic here — encoding/decoding into [UserModel] is the
  /// repository's job.
  Future<String?> getUserJson() async => (await _read())[ApiConfig.userKey];

  Future<void> setUserJson(String json) async {
    final data = Map<String, String>.of(await _read());
    data[ApiConfig.userKey] = json;
    await _write(data);
  }

  Future<void> clearUserJson() async {
    final data = Map<String, String>.of(await _read());
    data.remove(ApiConfig.userKey);
    await _write(data);
  }
}
