import 'package:smart_alarm/data/models/app_settings.dart';
import 'package:smart_alarm/data/providers/settings_local_provider.dart';

class SettingsRepository {
  SettingsRepository(this._localProvider);

  final SettingsLocalProvider _localProvider;

  AppSettings load() {
    try {
      return _localProvider.read();
    } catch (_) {
      return AppSettings.defaults;
    }
  }

  Future<bool> save(AppSettings settings) async {
    try {
      await _localProvider.write(settings);
      return true;
    } catch (_) {
      return false;
    }
  }
}
