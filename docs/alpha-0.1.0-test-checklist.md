# Smart Muslim — Alpha 0.1.0 User Testing Checklist

**Target Release**: Smart Muslim Phase 1 — Alpha 0.1.0  
**APK Binary**: `D:\Projects\Smart-Muslim\build\app\outputs\flutter-apk\app-debug.apk`  
**SHA-256**: `0F9C9BEC38132AEB629471B7AAA27224A6A4EB61F0ABA3C43AE478D37EC69AF0`  

---

## Testing Matrix

### A. Startup & Splash Screen
- [ ] **App Launch**: App opens quickly without delay or crash.
- [ ] **Splash Screen**: Display Crescent badge symbol, title, and dedication statement.
- [ ] **App Name**: Displays "المسلم الذكي" in Arabic cleanly.
- [ ] **Dedication Statement**: Displays verbatim: *"هذا التطبيق صدقة جارية عن أبي وأمي وأختي وعني وعن أهل بيتي"*.
- [ ] **Navigation**: Fades out smoothly after 3 seconds and navigates to Main Prayer Dashboard.

### B. Main Prayer Dashboard
- [ ] **Date & Location**: Displays current location badge (e.g. Cairo / Makkah) and current date.
- [ ] **Prayer Timings Display**:
  - [ ] Fajr time
  - [ ] Sunrise time
  - [ ] Dhuhr time
  - [ ] Asr time
  - [ ] Maghrib time
  - [ ] Isha time
- [ ] **Active & Next Prayer State**: Highlights next prayer in green, countdown timer decrements accurately every second.

### C. Location Management
- [ ] **GPS Granted**: Location auto-detects via GPS and updates prayer times.
- [ ] **GPS Denied**: Falls back gracefully to default Makkah location without crashing.
- [ ] **Manual City Selection**: User can select predefined cities (Cairo, Makkah, Riyadh, Dubai, London, NYC, etc.) from Settings.
- [ ] **Location Shift**: Prayer times recalculate instantly upon location change.

### D. Prayer Settings & Persistence
- [ ] **Calculation Method**: User can select MWL, Egyptian, Makkah, ISNA, Karachi, Tehran, Gulf, etc.
- [ ] **Asr Juristic Method**: User can toggle between Standard (Shafi'i/Maliki/Hanbali) and Hanafi Asr.
- [ ] **Settings Persistence**: Selected options remain saved upon app restart.

### E. Qibla Compass
- [ ] **Qibla Screen**: Displays Great Circle bearing from current coordinates to Kaaba.
- [ ] **Compass Dial**: Needle rotates smoothly as device is turned.
- [ ] **Calibration Guidance**: Guidance text instructs user to hold phone horizontally.
- [ ] **Sensor Availability**: Handles devices without compass sensors gracefully.

### F. Notifications & Adhan Alerts
- [ ] **Permissions**: Prompts for Notification and Exact Alarm permissions smoothly.
- [ ] **Foreground Alert**: Displays alert when prayer time arrives while app is open.
- [ ] **Background Alert**: System notification fires when app is in background or device locked.
- [ ] **Device Reboot**: Notifications automatically reschedule upon device restart.

### G. 100% Offline Mode
*Turn on Airplane Mode and test:*
- [ ] App launches and displays cached prayer schedule.
- [ ] Countdown timer continues working.
- [ ] Settings changes work locally.
- [ ] Qibla compass functions without network connection.

### H. UI & Accessibility
- [ ] **Arabic RTL**: Layout mirrored correctly right-to-left.
- [ ] **English LTR**: Layout switches left-to-right when device language is English.
- [ ] **Theme Switching**: Light and Dark modes render crisp contrast with zero text overlap.
- [ ] **Screen Sizes**: Adapts cleanly to small (5") and large (6.7"+) screen sizes.
