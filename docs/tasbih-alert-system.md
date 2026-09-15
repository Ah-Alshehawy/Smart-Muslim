# Tasbih / Misbaha Completion Alert System

## 1. Overview
The **Tasbih Completion Alert System** introduces subtle, non-intrusive target completion feedback for the electronic Misbaha in Smart Muslim. It replaces the redundant top-left AppBar reset button with a compact, elegant circular alert mode selector while keeping the bottom-left reset button as the sole reset control.

---

## 2. Supported Alert Modes & Cycling Sequence

The alert system provides four distinct states governed by `TasbihAlertMode`:

1. **Vibration Only (`TasbihAlertMode.vibration`)** [Default on clean install]
   - Visual: `Icons.vibration`
   - Arabic Label: "تنبيه بالاهتزاز"
   - Behavior: Delivers a single subtle haptic pulse upon reaching the target.
2. **Sound Only (`TasbihAlertMode.sound`)**
   - Visual: `Icons.volume_up_rounded`
   - Arabic Label: "تنبيه صوتي"
   - Behavior: Plays a gentle, neutral 150ms procedural chime upon reaching the target.
3. **Sound + Vibration (`TasbihAlertMode.soundAndVibration`)**
   - Visual: Composed side-by-side icons (`Icons.volume_up_rounded` + `Icons.vibration`)
   - Arabic Label: "تنبيه صوتي واهتزاز"
   - Behavior: Fires both the subtle vibration and gentle chime simultaneously.
4. **Off (`TasbihAlertMode.off`)**
   - Visual: `Icons.notifications_off_outlined`
   - Arabic Label: "التنبيه متوقف"
   - Behavior: Silent completion; no audio or haptic feedback is dispatched.

### Mode Cycling Order
Tapping the circular button advances sequentially and wraps indefinitely:
$$\text{Vibration} \longrightarrow \text{Sound} \longrightarrow \text{Sound + Vibration} \longrightarrow \text{Off} \longrightarrow \text{Vibration}$$

---

## 3. Feedback Characteristics

### Vibration
- **Methodology**: Utilizes `HapticFeedback.vibrate()` with graceful fallback to `HapticFeedback.mediumImpact()`.
- **Characteristics**: Directly engages the device's physical `Vibrator` hardware motor, ensuring tangible tactile feedback even on devices where touch-feedback haptics are disabled in battery settings.
- **Fail-Safe**: Wrapped in `try-catch` blocks to silently ignore platforms or hardware without vibration motors.

### Sound
- **Asset**: `assets/audio/tasbih_beep.wav` (~44 KB) and `android/app/src/main/res/raw/tasbih_beep.wav`.
- **Acoustic Design**: 500ms dual-harmonic sine chime (880 Hz fundamental + 1760 Hz harmonic) sampled at 44.1 kHz 16-bit PCM with peak amplitude 26,000, 20ms attack fade-in and smooth exponential decay. Meets Android ExoPlayer minimum buffer requirements without underruns.
- **Zero License Risk / Provenance**: Mathematically synthesized by `tool/generate_tasbih_beep.dart`. 100% public domain / zero copyright restrictions. Non-musical, non-alarming, and respectful of Islamic app standards.
- **Preloading & Reliability**: Preloaded via `initialize()` when entering `TasbeehCounterScreen`. Volume is pinned to 1.0. If audio fails or audio player is unavailable, gracefully falls back to `SystemSound.play(SystemSoundType.alert)`. Counter progression is never delayed or blocked.

---

## 4. Counter Semantics & Completion Boundary

### Target Reaching (33, 100, 1000)
- Completion feedback occurs **after** the visual counter displays the target value (e.g. `33 / 33`).
- Dispatched **strictly once** per completion event.
- Rapid successive taps around the boundary do not queue multiple overlapping sounds or vibrations.

### Cycle Wrapping
- After reaching target (e.g. 33), the next tap wraps `_counter` to `1` (the first dhikr of the new cycle), increments `_totalTasbeeh`, and resets the alert flag.
- The next alert will trigger when the counter reaches 33 again in the new cycle.

### Target Switching
- Switching targets (between 33, 100, and 1000) updates `_target`, resets current count to `0`, and rearms the completion alert for the newly chosen target.

### Reset Behavior
- Tapping the bottom-left "تصفير" button resets `_counter` to `0` and clears completion flags.
- **Resetting never fires a completion alert.**

---

## 5. Persistence

- Saved via `TasbihPreferences` utilizing `SharedPreferences` under the key `'tasbih_alert_mode'`.
- Persists across app sessions.
- Gracefully falls back to `TasbihAlertMode.vibration` if data is absent or malformed.

---

## 6. Accessibility & RTL Support

- Implements `Tooltip` and `Semantics(button: true, label: ...)` on the circular button.
- Localized via Flutter ARB (`app_ar.arb` and `app_en.arb`).
- RTL layout safe with `EdgeInsetsDirectional` in the AppBar `actions` slot, ensuring natural placement at the top-left in Arabic locales.

---

## 7. Automated Test Coverage

The test suite in `test/unit/tasbih_alert_system_test.dart` verifies:
- Default mode is vibration.
- 4-state cycling loop and fallback deserialization.
- SharedPreferences round-trip persistence for all 4 states.
- Completion alerts on 33, 100, and 1000 targets.
- Cycle wrapping from 33 to 1.
- Prevention of duplicate alerts.
- Reset to 0 produces zero alerts.
- Isolated execution of vibration, sound, both, and off.
- Audio asset existence, RIFF WAV header validity, and compact size (< 10 KB).
- Circular button rendering and cycling in the widget tree.
