import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// UI State Provider (Preference)
final audioEnabledProvider = StateProvider<bool>((ref) => false);

// Service Provider (Singleton access)
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final String _assetPath = 'audio/rainy_vibes.ogg'; // Kept original filename or user provided one?
  // User provided diff showed 'audio/rainy_vibes.ogg' in one turn and 'audio/rainy_lofi.ogg' in the manual diff.
  // I must check which file actually exists. 
  // Step 73 showed: "rainy_vibes.ogg".
  // The user's manual diff showed "rainy_lofi.ogg". WARNING.
  // I will check the file existence first. If rainy_lofi doesn't exist, I'll use rainy_vibes.

  bool _initialized = false;
  bool _enabled = false;

  double _volume = 0.0;
  static const double _targetVolume = 0.5;

  // ================= INIT =================

  Future<void> init() async {
    if (_initialized) return;

    final audioContext = AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: [
          AVAudioSessionOptions.mixWithOthers,
          AVAudioSessionOptions.defaultToSpeaker,
        ],
      ),
    );

    await _player.setAudioContext(audioContext);

    // CRITICAL: MediaPlayer mode avoids crackling on OGG
    await _player.setPlayerMode(PlayerMode.mediaPlayer);

    // Preload once
    await _player.setSource(AssetSource(_assetPath));
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.0);

    _initialized = true;
    print('[AudioService] Initialized');
  }

  // ================= PUBLIC API =================

  Future<void> enable() async {
    _enabled = true;
    await _start();
  }

  Future<void> disable() async {
    _enabled = false;
    await _fadeTo(0.0);
    await _player.pause(); // DO NOT stop()
  }

  bool get isEnabled => _enabled;

  // ================= INTERNAL =================

  Future<void> _start() async {
    if (!_initialized) await init();
    if (!_enabled) return;

    if (_player.state != PlayerState.playing) {
      await _player.resume();
    }

    await _fadeTo(_targetVolume);
  }

  Future<void> _fadeTo(double target) async {
    const int steps = 20;
    final double start = _volume;
    final double delta = (target - start) / steps;

    for (int i = 0; i < steps; i++) {
      _volume += delta;
      _volume = _volume.clamp(0.0, 1.0);
      await _player.setVolume(_volume);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await _player.setVolume(target);
    _volume = target;
  }
}
