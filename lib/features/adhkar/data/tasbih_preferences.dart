import 'package:shared_preferences/shared_preferences.dart';
import '../domain/tasbih_alert_mode.dart';

/// Manages persistence for Tasbih settings such as completion alert mode.
class TasbihPreferences {
  static const String _alertModeKey = 'tasbih_alert_mode';

  final SharedPreferences? _prefs;

  const TasbihPreferences([this._prefs]);

  /// Loads the saved [TasbihAlertMode]. Defaults to [TasbihAlertMode.vibration].
  Future<TasbihAlertMode> getAlertMode() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final storedValue = prefs.getString(_alertModeKey);
      return TasbihAlertMode.fromString(storedValue);
    } catch (_) {
      return TasbihAlertMode.vibration;
    }
  }

  /// Persists the selected [TasbihAlertMode].
  Future<void> setAlertMode(TasbihAlertMode mode) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_alertModeKey, mode.name);
    } catch (_) {
      // Gracefully handle persistence failure without crashing
    }
  }
}
