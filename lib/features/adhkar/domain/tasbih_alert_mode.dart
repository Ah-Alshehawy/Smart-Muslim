/// Supported alert modes for Tasbih target completion.
enum TasbihAlertMode {
  /// Vibration alert only (default).
  vibration,

  /// Sound alert only.
  sound,

  /// Both sound and vibration alerts simultaneously.
  soundAndVibration,

  /// Alerts disabled.
  off;

  /// Returns the next mode in the cycle:
  /// vibration -> sound -> soundAndVibration -> off -> vibration.
  TasbihAlertMode get next {
    switch (this) {
      case TasbihAlertMode.vibration:
        return TasbihAlertMode.sound;
      case TasbihAlertMode.sound:
        return TasbihAlertMode.soundAndVibration;
      case TasbihAlertMode.soundAndVibration:
        return TasbihAlertMode.off;
      case TasbihAlertMode.off:
        return TasbihAlertMode.vibration;
    }
  }

  /// Parses string to [TasbihAlertMode] with fallback to [TasbihAlertMode.vibration].
  static TasbihAlertMode fromString(String? val) {
    if (val == null) return TasbihAlertMode.vibration;
    return TasbihAlertMode.values.firstWhere(
      (e) => e.name == val,
      orElse: () => TasbihAlertMode.vibration,
    );
  }
}
