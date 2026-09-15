import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'adhan_sound_resolver.dart';

abstract class AdhanAudioService {
  Stream<PlayerState> get playerStateStream;
  bool get isPlaying;
  String? get currentlyPlayingSoundKey;

  Future<void> playSound(String soundKey);
  Future<void> stop();
  Future<void> dispose();
}

class JustAudioAdhanService implements AdhanAudioService {
  final AudioPlayer _player;
  String? _currentSoundKey;

  JustAudioAdhanService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  @override
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  @override
  bool get isPlaying => _player.playing;

  @override
  String? get currentlyPlayingSoundKey => _currentSoundKey;

  @override
  Future<void> playSound(String soundKey) async {
    final assetPath = AdhanSoundResolver.getAssetPath(soundKey);
    await _player.stop();
    _currentSoundKey = soundKey;
    try {
      if (kIsWeb) {
        // In Flutter Web with a custom base-href (/lite/), just_audio's setAsset
        // incorrectly constructs the URL by ignoring the base href.
        // We explicitly construct the URL relative to the base href.
        await _player.setUrl('assets/$assetPath');
      } else {
        await _player.setAsset(assetPath);
      }
      await _player.play();
    } catch (e) {
      _currentSoundKey = null;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _currentSoundKey = null;
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}
