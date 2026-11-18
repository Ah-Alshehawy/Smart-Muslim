# Smart Muslim — Pre-Release Security & Deployment Audit

- **Date:** 2026-11-03
- **Audited state:** local `master` @ `a8cd40e`; published APK `v0.2.0-dev.3.4`.
- **Mode:** read-only. Nothing was pushed, deployed or uploaded, and no key was created.
- **The only changes made:** this report file, and a local `flutter test` / `flutter analyze` run.

Classification legend: **VERIFIED** · **VERIFIED WITH LIMITATIONS** · **NOT VERIFIED** · **BLOCKED** · **REQUIRES OWNER APPROVAL**

---

## A. Executive Summary

**Decision: NO — not ready for a controlled release of the current `master` yet.** It becomes **CONDITIONAL** once blockers B1–B3 are cleared.

| # | Blocker | Status |
|---|---|---|
| B1 | **The published APK contains no adhan sound resources.** All 14 `res/raw` audio files were removed by release resource shrinking. Scheduled adhan notifications therefore cannot play the bundled adhan sounds. | VERIFIED (the published APK was inspected directly). **FIXED in source**, see B1 resolution below; not yet released or device-tested |
| B2 | **The only signing identity is the auto-generated debug key** at `%USERPROFILE%\.android\debug.keystore`, and it has no verified backup. If that file is lost or regenerated, every installed user loses the update path. | VERIFIED |
| B3 | **No physical-device validation** of `a8cd40e`, or of notifications, sound playback, reboot and update-over-install. | NOT VERIFIED |
| B4 | The upload script can publish a **stale APK** under a new tag. This already happened: `v0.2.0` and `v0.2.0-dev.3.4` carry byte-identical APKs. | VERIFIED |

### B1 resolution (2026-11-03) — VERIFIED WITH LIMITATIONS
- **Fix:** added `android/app/src/main/res/raw/keep.xml` with `tools:keep="@raw/*"`.
- **Rebuild:** local `flutter build apk --release`; nothing was uploaded.
  - `aapt2 dump resources` lists all 14 sounds: every `raw/adhan_*`, plus `raw/takbeer` and `raw/tasbih_beep`.
  - The signer is unchanged: SHA-256 `9B:43:D4…04:AA`.
  - The APK grew from 128,762,097 to 138,800,644 bytes.
  - `keep.xml` itself is also packaged as a tiny `raw/keep` entry. This is harmless.
- **Still to do:**
  - The build still carries `0.2.0-dev.3.4` / versionCode 9, so **bump the version before any release**.
  - Confirm on a device that the adhan **plays from a scheduled notification**.
- **The published APK is preserved locally:** `build/app/outputs/flutter-apk/app-release.apk` has been overwritten by this test build. An exact copy of the published APK is kept at `build/published/smart-muslim-v0.2.0-dev.3.4.apk` (SHA-256 `39f4b83c…`, gitignored), for over-install testing.

### Device test log
| Date | Build | Check | Result | Source |
|---|---|---|---|---|
| 2026-11-18 | `0.2.0-dev.4+10` (SHA-256 `d16b1e9b…`) | Update-over-install on top of the published `v0.2.0-dev.3.4` | **PASS**: installed as an update without uninstalling | Reported by the owner; not observed by the auditor |
| — | `0.2.0-dev.4+10` | Adhan plays from a scheduled notification, screen locked | **Not tested before release, by owner decision** (2026-11-19); to be reported after release | — |
| — | `0.2.0-dev.4+10` | Adhan after device reboot | Not tested before release, by owner decision | — |

### Signing-key backup log
| Date | Copy | Verification | Note |
|---|---|---|---|
| 2026-11-19 | `D:\Projects\Smart-Muslim-Signing-Backup\debug.keystore`, outside the git repo, on volume D: (a different volume from C:) | File SHA-256 identical to the original (`4851dbae…`); certificate SHA-256 `9B:43:D4…04:AA` | **Same machine.** This protects against a Windows reinstall on C:, but not against disk failure or loss of the device. An offline, encrypted second copy is still recommended. |

**Recommended next action (in order):**
1. Back up and verify the debug keystore (section C.6). This needs no approval and is risk-free.
2. Decide the long-term key strategy (section C.7). **REQUIRES OWNER APPROVAL**.
3. Fix B1: add `android/app/src/main/res/raw/keep.xml`, rebuild, and confirm with `aapt2` that the `raw/adhan_*` entries are present.
4. Run the device test plan in section G, then release.

---

## B. Git Audit

| Check | Result | Class |
|---|---|---|
| Current branch | `master` | VERIFIED |
| HEAD | `a8cd40ec70c2a0a3f1d27676b132e73095f0e202` — `fix: correct religious content integrity and adhan/prayer defaults` | VERIFIED |
| `a8cd40e` contained in | `master`, `fix/sharia-content-critical` | VERIFIED |
| `origin/master` | `e2d8aca`; local is **ahead by 1**, behind by 0 | VERIFIED |
| Working tree | Clean except one untracked unrelated file: `41IeegBJZjL._AC_SY879_.jpg` (an Amazon product photo) | VERIFIED |
| Ignored files relevant to signing | Only `android/local.properties` (SDK paths; no secrets) | VERIFIED |
| Secrets in `a8cd40e` | None. No keystore, `key.properties`, password, token or service-account file in the diff. | VERIFIED |
| Credential files tracked anywhere in git | None (`*.jks`, `*.keystore`, `key.properties`, service-account JSON) | VERIFIED |
| `.gitignore` coverage | `android/.gitignore` excludes `key.properties`, `**/*.keystore`, `**/*.jks` | VERIFIED |

**Discrepancies vs. the reported state**
- **None material.**
- Remote tags `v0.2.0` and `v0.2.0-dev.3.4` exist on GitHub but are not fetched locally. This is informational only.
- The commit author email is `sits2025@gmail.com`, which comes from the local git config.

---

## C. Signing Security

### C.1 Signing configuration — VERIFIED
- `android/app/build.gradle.kts:30`: `release { signingConfig = signingConfigs.getByName("debug") }`.
- There is no `android/key.properties`, no release `signingConfigs` block, and no signing-related environment variables.

### C.2 Identity in use — VERIFIED
| Item | Value |
|---|---|
| Classification | **Android debug key** (auto-generated by the Android tooling) |
| Certificate DN | `C=US, O=Android, CN=Android Debug` |
| Certificate SHA-256 | `9B:43:D4:6C:66:ED:1B:24:2E:41:72:E6:4E:F1:0E:A9:5E:D0:68:A8:9C:00:C6:D9:C4:46:ED:7E:EA:84:04:AA` |
| Certificate SHA-1 | `4B:92:33:20:E7:1F:64:C1:B9:4A:C0:CE:0F:DA:C5:0B:89:8B:05:14` |
| Keystore location | `%USERPROFILE%\.android\debug.keystore` on **this PC**. PKCS12, alias `androiddebugkey`, created 2026-08-25. |
| Certificate validity | 2026-08-25 → 2056-08-17 |
| Signature schemes in published APK | v2 only (no v1, v3 or v4) |

### C.3 Published APK vs. local key — VERIFIED
- The GitHub asset digest for `smart-muslim.apk` in both releases is `sha256:39f4b83c…3640b950`.
- This is byte-identical to the local `build/app/outputs/flutter-apk/app-release.apk`, so the published APK was inspected directly without downloading it.
- `apksigner verify --print-certs` shows the published APK's signer is the debug certificate above.
- The local `debug.keystore` holds **the same** certificate (fingerprints match).

**Correction to the earlier report:** the key is **not** on a "previous PC". It is on the current machine, and it is currently present and usable.

### C.4 Recoverability — VERIFIED WITH LIMITATIONS
- **Recoverable now:** yes. The file exists, and its entry and fingerprint can be read.
- **Backup:** none found or verified. I did not search other drives or cloud storage. **This is a single point of failure.**
- **Protection:** the debug keystore uses the publicly known default password. Anyone who obtains the file can sign "updates" that installed copies will accept.
- **Silent-regeneration hazard:** if the file is deleted, the Android tooling **silently creates a new debug key** on the next build. That build would look normal but could not update existing installs.

### C.5 Reproducibility on another machine — VERIFIED WITH LIMITATIONS
- A build on another machine reproduces the identity **only if** this exact `debug.keystore` is copied to that machine's `%USERPROFILE%\.android\`.
- Otherwise that machine's own debug key is used, and updates fail with "App not installed / package conflicts".
- This follows from the configuration; I did not test it on a second machine.

### C.6 Securing the existing identity (no approval needed, nothing changes for users)
1. Copy `%USERPROFILE%\.android\debug.keystore` to **two offline locations**, for example an encrypted USB drive and an encrypted password-manager attachment. Never put it in the repo, on Firebase, on GitHub, or in a public cloud folder.
2. Verify each copy:
   - Its `sha256sum` must match the original's (it starts with `4851dbaee66d920…`).
   - `keytool -list -v -keystore <copy>` must show SHA-256 `9B:43:D4:…:04:AA`.
3. Recovery drill (optional but recommended): on a second machine, place the copy at `~/.android/debug.keystore`, build, and run `apksigner verify --print-certs`. The certificate must match.
4. Add a pre-upload guard to the release script (a recommendation, not implemented here): abort if the APK signer's SHA-256 is not `9B:43:D4…04:AA`.

### C.7 Migration options — REQUIRES OWNER APPROVAL
| Option | What happens to the ~55 existing installs | Pros | Cons |
|---|---|---|---|
| **1. Keep the debug key permanently** (back it up per C.6) | Nothing; updates keep working | Zero user disruption | Weak protection (known password). Google Play rejects debug-signed apps, so a future move to Play would force a key change anyway. |
| **2. Switch to a new release key now** | Every user must **uninstall and reinstall once**, losing local settings, last-read page and adhan choices | Clean identity, Play-compatible, cheapest while the user base is small | One-time disruption: needs an in-app or website notice and a clear version cut-over |
| **3. Key rotation via APK Signature Scheme v3 lineage** (`apksigner rotate`, then sign with the lineage) | Seamless on Android 9+. Android 7–8 devices (minSdk is 24) keep validating v2 with the **old** key, so the old key must still be kept and used. | No reinstall on most devices | Manual `apksigner` pipeline (not native to Gradle), more complex, and the old debug key stays in use |
| **4. Defer until Play onboarding** | No change now | — | The disruption grows with every new download |

Recommendation for the owner: do **C.6 immediately whatever you decide**, then choose Option 2 or 1. Do not create or switch keys until the user-impact notice is ready.

---

## D. Android Release Pipeline

| Item | Finding | Class |
|---|---|---|
| Build command | `flutter build apk --release`, via `upload_apk_release.ps1 -BuildFirst` or `tool/release.dart` | VERIFIED |
| Build variant | release; `isMinifyEnabled = true`; not debuggable | VERIFIED |
| Signing | Debug key (see C) | VERIFIED |
| Output path | `build/app/outputs/flutter-apk/app-release.apk`, copied to `smart-muslim.apk` before upload | VERIFIED |
| APK type | **Universal**: `arm64-v8a`, `armeabi-v7a`, `x86_64`; minSdk 24, targetSdk 36 | VERIFIED |
| Size | 128,762,097 bytes (~123 MiB) | VERIFIED |
| **Adhan resources in APK** | **`res/raw` contains only `firebase_common_keep`; all `adhan_*.mp3/ogg`, `takbeer.ogg` and `tasbih_beep.wav` raw resources were removed.** The `assets/flutter_assets/assets/audio/*` copies (used for in-app preview) are present. | **VERIFIED — BLOCKER B1** |
| Target repo | `gh release create $Tag smart-muslim.apk --latest` against the repo of the current checkout: `Ah-Alshehawy/Smart-Muslim` | VERIFIED |
| Asset replacement | Fallback is `gh release upload $Tag --clobber`. **But** in Windows PowerShell 5.1 a failing native `gh` call does not throw, so the `catch` fallback never runs and the script still prints success. | VERIFIED WITH LIMITATIONS (read from code; not executed) |
| Stale-APK risk | Without `-BuildFirst` the script uploads whatever `app-release.apk` exists, and it never checks `versionName` against the tag. `v0.2.0` (09:49) and `v0.2.0-dev.3.4` (10:26) carry the same APK digest. | **VERIFIED — B4** |
| Permanent URL | `…/releases/latest/download/smart-muslim.apk` returns 200 with 128,762,097 bytes and resolves to `v0.2.0-dev.3.4` (marked Latest). It stays valid after `--clobber`, as long as the new release is marked Latest and the asset name stays `smart-muslim.apk`. | VERIFIED |
| Tag semantics | Under semver, `v0.2.0` ranks **above** `v0.2.0-dev.3.4`, yet it holds the dev.3.4 build. This is confusing for users and for any future version check. | VERIFIED |
| Automatic publishing | No `.github/workflows`; nothing publishes without a manual run | VERIFIED |
| Accidental debug build | `upload_apk_release.ps1` only picks `app-release.apk`. `tool/release.dart --mode=debug` writes a different filename to `releases/` and does not upload. Risk is low, but note the "release" is debug-*signed* anyway. | VERIFIED |
| Release manifest honesty | `tool/release.dart` hard-codes `flutterAnalyze: 'PASS (0 issues)'` and "42 Nawawi" whatever the actual results | VERIFIED |
| Exact alarms | Both `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` are declared. This is fine for sideloading; it is a Play policy issue only. | VERIFIED |

---

## E. Firebase Hosting (read-only)

| Item | Finding | Class |
|---|---|---|
| Project ID | `smart-muslim-ad4f6` (`.firebaserc` default) | VERIFIED |
| Sites | `smart-muslim` (→ smart-muslim.web.app) and `smart-muslim-ad4f6` (default site) | VERIFIED (`firebase hosting:sites:list`) |
| Configured target | Only the `smart-muslim` site. `public: public_html`, rewrite `/lite/** → /lite/index.html`. | VERIFIED |
| Landing page | `website/*` copied to `public_html/` by `build_web.ps1` | VERIFIED |
| Web app | `flutter build web --base-href /lite/` copied to `public_html/lite/` | VERIFIED |
| Separation | Landing page and web app are **one Hosting site, separated by path** (`/` and `/lite/`) and deployed together. That is the current design, preserved. | VERIFIED |
| Live = local | Live `index.html` hash = `website/index.html`; live `/lite/main.dart.js` hash = `public_html/lite/main.dart.js` | VERIFIED |
| Download button | Live landing links to `…/releases/latest/download/smart-muslim.apk` | VERIFIED |
| APK on Firebase | `website/download/` is an empty untracked folder, and `build_web.ps1` copies no APK. No APK is deployed on `smart-muslim.web.app`. | VERIFIED |
| Android pipeline touching Firebase | No; the upload script only calls `gh` | VERIFIED |
| Credentials | `firebase_options.dart` / `google-services.json` hold public client config only. No service-account or admin SDK files are in git or in `public_html`. | VERIFIED |
| **Stale default site** | `smart-muslim-ad4f6.web.app` serves an **old landing page** (Tailwind CDN version) with links to `/downloads/app-release.apk` and `.ipa`, which both return **404**, and an old `/lite/`. It is not managed by `firebase.json`. | VERIFIED — **REQUIRES OWNER APPROVAL** to redirect or retire |

---

## F. Update Mechanism

| Question | Finding | Class |
|---|---|---|
| Installed version | `PackageInfo.version` (versionName) | VERIFIED |
| Latest version source | Remote Config `latest_version` / `force_update_version` | VERIFIED |
| Remote Config contents | **No published parameters**, so only the in-app defaults apply (`latest 0.1.0`, `force 0.0.1`). The status is therefore always `upToDate`. | VERIFIED (`firebase remoteconfig:get`) |
| Update URL | Default changed in `a8cd40e` to the permanent GitHub link. **Not yet in any published APK.** | VERIFIED |
| Visible UI | Only `forced` is handled (a full-screen block). `available` is computed and **never shown**. | VERIFIED |
| Offline / failure | Fetch errors are caught and defaults apply. **But** `main()` awaits the fetch with a **1-minute timeout before `runApp`**, so a poor network means a long splash screen. | VERIFIED |
| Repeated prompts | Not applicable today (no prompt UI exists) | VERIFIED |
| Version comparison | `_parseVersion` drops everything after `-` and ignores the build number, so `0.2.0-dev.3.4`, `0.2.0-dev.4` and `0.2.0` compare **equal**. Dev-to-dev updates can never be detected. | VERIFIED |
| Kill-switch risk | A mistaken `force_update_version` in Remote Config would lock every user out with no bypass | VERIFIED WITH LIMITATIONS |

**Recommended solution (keeps the architecture):**
1. Publish a small static file, `version.json`, on the existing Firebase landing site. It holds `versionCode` (an integer), `versionName`, `minSupportedVersionCode` and `apkUrl` (the permanent GitHub URL).
2. Update it in the same release step that uploads the APK.
3. Compare **`versionCode`** (the build number), not the version-name string.
4. Run the check **after** `runApp`, in the background, with a ~5-second timeout.
5. Show a dismissible banner for `available`, at most once per `versionCode`, remembered in SharedPreferences. Keep the hard block only for `< minSupportedVersionCode`.
6. Remote Config then becomes optional.
7. An alternative is the GitHub `releases/latest` API (unauthenticated limit: 60 requests per hour per IP; acceptable for this scale).

Nothing was implemented during this audit.

---

## G. Religious Content & Prayer Calculation — review of `a8cd40e`

| Change | Finding | Class |
|---|---|---|
| Quranic text in adhkar | Ayat al-Kursi and the Mu'awwidhat now equal the Tanzil text **exactly**. They were extracted by script, not typed, and a test enforces it. The Tanzil copyright block is intact. | VERIFIED |
| Tanzil attribution in-app | The licence requires attribution plus a link to tanzil.net in the app. **Still missing** from the About screen. | VERIFIED — open item |
| Quranic font | `'Amiri'`/`'Tajawal'` are referenced but **not bundled**, and `google_fonts` is unused, so rendering falls back to the system font. The Uthmani marks (ٱ ۥ ـٰ) in the adhkar and the Quran text mode may render imperfectly on some devices. | VERIFIED WITH LIMITATIONS (device check needed) |
| Dhikr truncation | No `...` remains in any dhikr. Three hadith-based adhkar (ids 3, 12, 51) are labelled "مختصر" ("abridged") rather than completed: **completing them requires copying the full text from Sahih Muslim by a qualified reviewer**, not AI. | VERIFIED |
| Fadl vs. note | The narrated reward ("الفضل الوارد") and the editorial note ("فائدة") are now separate fields with distinct UI. 5 unsupported reward claims were removed. The remaining fadl texts are **paraphrases** of the narrations, labelled as such. | VERIFIED |
| Gradings | Not changed in this commit. Items flagged in `docs/sharia-content-and-product-review.md` §2.4 (e.g. dhikr 7, the morning/evening salawat hadith, and dhikr 5, «رضيت بالله رباً») **require qualified Sunni hadith review**. | REQUIRES SCHOLARLY REVIEW |
| Tafsir | The placeholder and the 11 paraphrased entries were removed, and the section is hidden when no verbatim text exists (currently every verse). | VERIFIED |
| Adhan defaults | Default Maghrib → general Makkah adhan. The legacy key `madinah` → general adhan (also fixes existing saved preferences). Fajr's default is still `adhan.ogg`; **whether it contains «الصلاة خير من النوم» was not checked by listening.** | VERIFIED / NOT VERIFIED (audio) |
| France (UOIF) | Fajr 12° / Isha 12° instead of 0°/0°; a Paris test asserts more than 45 minutes of twilight | VERIFIED |
| Tehran method | The `adhan` package sets `maghribAngle: 4.5`, which places Maghrib **after** sunset. This is a calculation parameter reflecting a Ja'fari jurisprudential position. **No change was made.** Whether to keep it, relabel it, or remove it is an owner and scholar decision. **Note:** methods are persisted **by enum index**, so removing or reordering entries would silently change the saved method of existing users (France would shift); a migration must accompany any change. | REQUIRES OWNER APPROVAL + SCHOLARLY REVIEW |
| Terminology | Asr options read «الجمهور (الشافعي والمالكي والحنبلي)» and «المذهب الحنفي». These are accurate. | VERIFIED |

---

## H. Testing & Quality

| Check | Result | Class |
|---|---|---|
| `flutter test` (all) | **114 passed** (112 unit + 2 widget), 0 failed | VERIFIED (re-run 2026-11-03) |
| `flutter analyze` | 5 issues: 1 warning (unused `dart:io` import) and 4 infos, all in `adhan_sound_resolver.dart` and present before `a8cd40e` | VERIFIED |
| Physical device | **None performed.** Automated tests are not device validation. | NOT VERIFIED |

**Missing tests and validation (all NOT VERIFIED):**
- **Update-over-install:** install the published `v0.2.0-dev.3.4`, then install the new build over it. It must succeed without uninstalling, and settings must be retained.
- **Signature compatibility:** an automated `apksigner` fingerprint check in the release step.
- **Adhan:**
  - The release APK contains `raw/adhan_*` (aapt2 check).
  - Each per-prayer sound plays from a **scheduled notification** with the screen locked.
  - Silent mode and Do-Not-Disturb behaviour.
- **Reboot:** notifications are rescheduled after a device restart. **7-day expiry:** behaviour if the app is not opened for more than 7 days.
- **Timezone and DST:** change the device timezone; check a DST transition for a European city; check a city whose timezone differs from the device's.
- **Offline:** cold start in airplane mode (splash duration, prayer times, Quran, adhkar).
- **Update:** detection and download through the permanent URL (once a UI exists).
- **Language:** Arabic RTL layout. English LTR is currently non-functional (locale hard-coded to `ar`).
- **Firebase web:** `/lite/` deep-link refresh routing; landing download button on mobile browsers.
- **Device matrix:** Android 7/8 (minSdk 24), Android 12, 13 (notification permission), 14 and 15/16 (exact alarms, full-screen intent), plus at least one 32-bit `armeabi-v7a` phone.

---

## I. Release Checklist

**Must do before publishing**
- [ ] Back up `debug.keystore` to 2 offline encrypted locations, and verify the hash and fingerprint of each copy (C.6).
- [ ] Owner decision on the key strategy (C.7). **REQUIRES OWNER APPROVAL**.
- [x] Fix B1: add `res/raw/keep.xml` keeping `@raw/*`, rebuild, and check `aapt2 dump resources` lists every `raw/adhan_*`. Done on 2026-11-03 in a local build; device check still pending.
- [ ] Bump the version (`pubspec.yaml`: new versionName **and** versionCode > 9).
- [ ] Build fresh with `-BuildFirst`, then check:
  - `aapt2 badging` versionName/versionCode match the tag;
  - the `apksigner` SHA-256 is `9B:43:D4…04:AA` (or the new key, per the decision).
- [ ] Device test plan (section H), at minimum update-over-install, scheduled adhan sound, reboot and offline.
- [ ] Push `master` (`a8cd40e` and the fix commits). **REQUIRES OWNER APPROVAL**.
- [ ] Create the GitHub release with asset name `smart-muslim.apk`, marked **Latest**; then confirm the permanent URL returns the new size and digest. **REQUIRES OWNER APPROVAL**.

**Should do soon**
- [ ] Make the upload script fail on a non-zero `gh` exit code, and refuse a stale or mismatched APK.
- [ ] Correct `tool/release.dart`'s hard-coded QA status and claims.
- [ ] Add Tanzil / King Fahd Complex / rn0x attribution screen.
- [ ] Bundle the Quranic font (Amiri / KFGQPC).
- [ ] Implement the `version.json` update check (section F).
- [ ] Decide on the stale `smart-muslim-ad4f6.web.app` site (redirect or retire). **REQUIRES OWNER APPROVAL**.
- [ ] Clarify the `v0.2.0` vs `v0.2.0-dev.3.4` tags (mark or rename on the next release; do not delete without approval).
- [ ] Scholarly review: hadith gradings (§2.4 of the Sharia review), the abridged adhkar texts, the Tehran method, and the Fajr adhan audio.
