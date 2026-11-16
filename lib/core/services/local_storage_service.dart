import 'package:get_storage/get_storage.dart';

/// Owns the local key-value store used by the app's data providers.
///
/// Create it once during application startup, before any repository reads
/// or writes happen.
class LocalStorageService {
  LocalStorageService._(this._storage);

  final GetStorage _storage;

  static Future<LocalStorageService> create() async {
    await GetStorage.init();
    return LocalStorageService._(GetStorage());
  }

  T? read<T>(String key) => _storage.read<T>(key);

  Map<String, dynamic>? readMap(String key) {
    final value = _storage.read<dynamic>(key);
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Future<void> write(String key, dynamic value) => _storage.write(key, value);

  Future<void> remove(String key) => _storage.remove(key);
}
