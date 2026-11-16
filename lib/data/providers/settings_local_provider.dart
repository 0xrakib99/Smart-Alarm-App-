import 'package:smart_alarm/core/services/local_storage_service.dart';
import 'package:smart_alarm/data/models/app_settings.dart';

class SettingsLocalProvider {
  SettingsLocalProvider(this._storage);

  final LocalStorageService _storage;

  static const String _settingsKey = 'settings_v1';

  AppSettings read() {
    final map = _storage.readMap(_settingsKey);
    if (map == null) {
      return AppSettings.defaults;
    }
    return AppSettings.fromMap(map);
  }

  Future<void> write(AppSettings settings) {
    return _storage.write(_settingsKey, settings.toMap());
  }
}
