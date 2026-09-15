# Smart Muslim — Quality Gates & Testing Strategy

To satisfy the **Production-Grade Standard**, Phase 1 and all future phases must pass an explicit **18-Point Quality Gate Matrix** before release approval.

---

## 1. The 18 Quality Gates Checklist

| # | Quality Gate | Verification Method | Pass Criteria |
| :--- | :--- | :--- | :--- |
| **1** | **Unit Tests** | `flutter test test/unit/` | 100% pass rate on domain logic, BLoCs, and utilities. |
| **2** | **Integration Tests** | `flutter test integration_test/` | Complete data flow from repository to local Drift SQLite store. |
| **3** | **Prayer Calculation Verification** | Astronomical Test Suite | Computations for Cairo, Makkah, London, Oslo, Tokyo, NYC match observatory baselines within 60s. |
| **4** | **Qibla Bearing Verification** | Spherical Trigonometry Tests | Math output matches exact Great Circle calculations for global test points. |
| **5** | **Notification Scheduling Tests** | Platform Mock Adapters | Correct notification payload and exact fire time scheduled for next 10 days. |
| **6** | **Permission Handling Tests** | Permission Suite | Graceful fallback when Location, Notification, or Exact Alarm permissions are denied. |
| **7** | **Offline Operation Test** | Airplane Mode Verification | 100% app functionality without internet connectivity. |
| **8** | **Device Boot Reschedule Test** | `adb shell am broadcast -a android.intent.action.BOOT_COMPLETED` | Receiver reschedules all pending prayer alarms on device reboot. |
| **9** | **Timezone Shift Test** | System Timezone Simulation | App detects timezone shift and updates prayer schedule immediately. |
| **10** | **Location Shift Test** | Location Provider Mock | Moving > 10km triggers schedule recalculation and notification refresh. |
| **11** | **RTL / LTR Layout Test** | Golden Widget Tests | Mirroring correctness, zero text clipping or overlap in Arabic and English modes. |
| **12** | **Light / Dark Mode Test** | UI Theme Verification | WCAG AA contrast ratio compliance across all screens in both themes. |
| **13** | **Android Physical Device Test** | Physical Testing (Android 12-16) | Verified on real hardware across Samsung, Xiaomi, Pixel devices. |
| **14** | **iOS Physical Device Test** | Physical Testing (iOS 15-18) | Verified on real iPhone hardware with `UNUserNotificationCenter`. |
| **15** | **Performance & Frame Rate Test** | Flutter DevTools Profiler | Sustained 60/120 fps during Qibla compass rotation and page navigation. |
| **16** | **Battery Impact Review** | Android Energy Profiler / iOS Instruments | Zero CPU leaks or unnecessary background battery drain. |
| **17** | **Security & Privacy Audit** | Code Inspection & Network Proxy | Zero third-party analytics, zero ad SDKs, zero unauthorized network calls. |
| **18** | **Data Governance & License Audit** | Checksum & License Script | 100% source attribution and SHA-256 checksum verification. |
