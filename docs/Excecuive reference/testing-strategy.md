# Smart Muslim — Testing Strategy & Quality Assurance Framework

To satisfy the **Production-Grade Standard (Section 21)**, every release must pass an explicit 15-point verification matrix.

## 1. Automated Testing Pipeline

### Unit Tests
- **Prayer Calculation Accuracy**: Verify astronomical calculation outputs across coordinates (Cairo, Makkah, London, Oslo high-latitude, Tokyo, New York, Sydney) against verified observatory baselines.
- **Qibla Math**: Test Great Circle formula outputs against known bearings to Makkah.
- **Domain Business Logic**: Test BLoCs and state transitions using `bloc_test`.

### Integration Tests
- **Database Caching & Offline Pipeline**: Verify local SQLite read/write operations without network connectivity.
- **Notification Scheduling**: Verify notification queue generation for next 7-14 days.

### UI & Golden Widget Tests
- **RTL / LTR Rendering**: Verify layout mirror behavior in Arabic (RTL) vs English (LTR).
- **Theme Switching**: Verify color contrast and typography in Light and Dark mode.

---

## 2. Manual & Device QA Matrix

1. **Background & OS Restrictions Verification**:
   - Android Doze Mode testing (`adb shell dumpsys deviceidle force-idle`).
   - iOS Background Refresh & App termination testing.
   - Device Reboot test (Verify `BOOT_COMPLETED` receiver reschedules notifications).
2. **Offline Mode Verification**: Enable Airplane mode and verify complete functionality of prayer times, countdowns, settings changes, and Qibla compass.
3. **Location Services Permutations**:
   - GPS permission granted.
   - GPS permission denied -> fallback manual city selection dialog.
   - Location change from Cairo to Riyadh -> automatic recalculation prompt/update.
4. **RTL & Localization Integrity**:
   - Zero hardcoded English strings in Arabic UI.
   - Proper numeral formatting (Western Arabic `123` vs Eastern Arabic `١٢٣` based on user settings).
