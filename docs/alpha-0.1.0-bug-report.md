# Smart Muslim — Alpha 0.1.0 Bug Report Log

**Release Version**: Smart Muslim Phase 1 — Alpha 0.1.0 (Fix Pack 1)  
**Build Date**: September 1, 2026  
**Build Number**: `1.0.0+1`  
**APK Hash (SHA-256)**: `26E4F1BBA062310FD69F4F7AB59201DD0DB2182DFE9FB2260C59A09ACF4575CE`  

---

## Resolved Bug Log

### Bug ID: BUG-001 — Location Selection Freeze in Settings
- **Severity**: High
- **Device Model**: Physical Android Device (User Hardware Test)
- **Android Version**: Android 12 / 13 / 14
- **Summary**: Tapping "التحديد التلقائي عبر الـ GPS" or selecting a manual city in Settings caused choices to freeze/lock up, only back button dismissed it, and repeating caused the same behavior.
- **Root Cause**:
  1. `Geolocator.getCurrentPosition()` without an instant last-known position check or strict timeout hung indefinitely on Android when GPS signal lock was delayed or blocked.
  2. `PrayerSettingsScreen` was not listening reactively to BLoC state via `BlocBuilder`, missing active selection checkmarks and loading feedback.
- **Fix Implemented**:
  1. `LocationService`: Integrated instant `getLastKnownPosition()` fallback (0ms) and added strict 3-second timeout (`.timeout(const Duration(seconds: 3))`) with fallback to Makkah location.
  2. `PrayerSettingsScreen`: Wrapped UI in `BlocBuilder<PrayerBloc, PrayerState>`, added active selection checkmark icons (`Icons.check_circle`), and introduced feedback SnackBar alerts upon location selection.
- **Retest Result**: 100% PASS (Static analysis & automated test suite verified).
- **Status**: **RESOLVED / FIXED IN ALPHA 0.1.0 (FIX PACK 1)**
