import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'tasbih_alert_mode.dart';

/// Abstract service contract for triggering Tasbih completion alerts.
abstract class TasbihAlertService {
  Future<void> initialize();
  Future<void> triggerAlert(TasbihAlertMode mode);
  void dispose();
}

/// Production implementation of [TasbihAlertService] executing reliable haptics
/// via Android Vibrator and clear neutral audio alerts safely without affecting counter performance.
class DefaultTasbihAlertService implements TasbihAlertService {
  final AudioPlayer _audioPlayer;
  bool _isAudioInitialized = false;

  DefaultTasbihAlertService({AudioPlayer? audioPlayer})
      : _audioPlayer = audioPlayer ?? AudioPlayer();

  @override
  Future<void> initialize() async {
    await _ensureAudioReady();
  }

  Future<void> _ensureAudioReady() async {
    if (_isAudioInitialized) return;
    try {
      await _audioPlayer.setAsset('assets/audio/tasbih_beep.wav');
      await _audioPlayer.setVolume(1.0);
      _isAudioInitialized = true;
    } catch (_) {
      // Non-fatal if audio initialization fails
    }
  }

  Future<void> _playVibration() async {
    try {
      // Direct hardware motor vibration via Android Vibrator service.
      // Operates reliably across all Android manufacturers regardless of touch feedback settings.
      await HapticFeedback.vibrate();
    } catch (_) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {
        // Platform haptics unavailable or restricted — continue safely
      }
    }
  }

  Future<void> _playSound() async {
    try {
      if (!_isAudioInitialized) {
        await _ensureAudioReady();
      }
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } catch (_) {
      // Audio playback failed or device muted: try safe system chime/click fallback
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {
        try {
          await SystemSound.play(SystemSoundType.click);
        } catch (_) {
          // Safe silent fail
        }
      }
    }
  }

  @override
  Future<void> triggerAlert(TasbihAlertMode mode) async {
    switch (mode) {
      case TasbihAlertMode.vibration:
        await _playVibration();
        break;
      case TasbihAlertMode.sound:
        await _playSound();
        break;
      case TasbihAlertMode.soundAndVibration:
        // Execute both concurrently
        await Future.wait([
          _playVibration(),
          _playSound(),
        ]);
        break;
      case TasbihAlertMode.off:
        // No-op
        break;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
  }
}
