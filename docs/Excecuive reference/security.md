# Smart Muslim — Security & Privacy Architecture

## 1. Zero Tracking & Data Privacy Policy
- **Zero Third-Party Analytics**: No Google Analytics, Firebase Analytics, Mixpanel, or telemetry SDKs.
- **Zero Advertising SDKs**: No AdMob, Unity Ads, or tracking beacons.
- **Zero Data Monetization**: No selling, logging, or transmitting of user data to remote servers.

---

## 2. Permission Scoping & Transparency

| OS Permission | Usage Rationale | User Control |
| :--- | :--- | :--- |
| `ACCESS_FINE_LOCATION` | Real-time GPS coordinate acquisition for accurate prayer times and Qibla compass. | Optional. User can choose manual city selection instead. |
| `POST_NOTIFICATIONS` | Alerting user when prayer time arrives (Adhan / pre-prayer alerts). | Optional. Managed in-app and in OS system settings. |
| `SCHEDULE_EXACT_ALARM` | Scheduling precise prayer alerts on Android 12+. | Required only if exact Adhan timing is desired. |
| `FOREGROUND_SERVICE` | Playing full Adhan audio seamlessly when app is backgrounded on Android. | Triggered only at prayer time when Adhan audio is enabled. |

---

## 3. Data Storage & Integrity
- All local user preferences (selected calculation method, preferred reciter, manual location) are stored locally in secure on-device preferences.
- Embedded Islamic datasets (Quran, Hadith, Tafsir) are immutable SQLite databases protected by SHA-256 integrity checksums to prevent tamper or corruption.
