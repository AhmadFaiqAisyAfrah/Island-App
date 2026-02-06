import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Available music tracks
enum MusicTrack {
  rainy,
  forest,
  night,
  snow,
  ocean,
}

/// Singleton service for managing background music playback.
///
/// DESIGN GUARANTEES:
/// - ONE AudioPlayer instance only
/// - Native looping (ReleaseMode.loop)
/// - Deterministic playback (no resume() trap)
/// - Smooth fade in/out
/// - Safe across widget rebuilds & focus sessions
class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  static MusicService get instance => _instance;

  MusicService._internal();

  late final AudioPlayer _player;
  bool _isInitialized = false;
  bool _isPlaying = false;

  double _currentVolume = 0.7;
  MusicTrack _currentTrack = MusicTrack.rainy;

  final _playingController = StreamController<bool>.broadcast();
  final _trackController = StreamController<MusicTrack>.broadcast();

  Stream<bool> get playingStream => _playingController.stream;
  Stream<MusicTrack> get trackStream => _trackController.stream;

  bool get isPlaying => _isPlaying;
  MusicTrack get currentTrack => _currentTrack;
  double get currentVolume => _currentVolume;

  /// Initialize once at app startup
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _player = AudioPlayer();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.0);

      _player.onPlayerStateChanged.listen((state) {
        final playingNow = state == PlayerState.playing;
        if (_isPlaying != playingNow) {
          _isPlaying = playingNow;
          _playingController.add(_isPlaying);
        }
      });

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('🎵 MusicService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ MusicService init error: $e');
      }
    }
  }

  /// Asset path resolver
  String _getTrackPath(MusicTrack track) {
    switch (track) {
      case MusicTrack.rainy:
        return 'audio/rainy_vibes.ogg';
      case MusicTrack.forest:
        return 'audio/forest_vibes.ogg';
      case MusicTrack.night:
        return 'audio/night_vibes.ogg';
      case MusicTrack.snow:
        return 'audio/snow_vibes.ogg';
      case MusicTrack.ocean:
        return 'audio/ocean_vibes.ogg';
    }
  }

  /// Start playing the currently selected track
  /// This ALWAYS works (no resume trap)
  Future<void> playCurrentTrack() async {
    if (!_isInitialized) return;

    try {
      await _player.play(
        AssetSource(_getTrackPath(_currentTrack)),
        volume: 0.0,
      );

      await _fadeVolume(0.0, _currentVolume, 400);

      if (kDebugMode) {
        debugPrint('▶️ Playing $_currentTrack');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Play error: $e');
      }
    }
  }

  /// Switch track (used before focus starts)
  Future<void> switchTrack(MusicTrack track) async {
    if (!_isInitialized) return;
    if (_currentTrack == track) return;

    try {
      if (_isPlaying) {
        await stop();
      }

      _currentTrack = track;
      _trackController.add(track);

      if (kDebugMode) {
        debugPrint('🔄 Switched track to $track');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Switch track error: $e');
      }
    }
  }

  /// Stop playback with fade out
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      if (_isPlaying) {
        await _fadeVolume(_currentVolume, 0.0, 300);
        await _player.stop();
      }

      if (kDebugMode) {
        debugPrint('⏹ Music stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Stop error: $e');
      }
    }
  }

  /// Called when Begin Focus is pressed
  Future<void> startForFocus() async {
    await stop();
    await playCurrentTrack();
  }

  /// Set volume safely
  Future<void> setVolume(double volume) async {
    _currentVolume = volume.clamp(0.0, 1.0);
    if (_isPlaying) {
      await _player.setVolume(_currentVolume);
    }
  }

  /// Smooth volume fade
  Future<void> _fadeVolume(double start, double end, int durationMs) async {
    const steps = 20;
    final stepDuration = durationMs ~/ steps;
    final delta = (end - start) / steps;

    for (var i = 0; i <= steps; i++) {
      final v = (start + delta * i).clamp(0.0, 1.0);
      await _player.setVolume(v);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }

  /// Dispose only when app exits
  void dispose() {
    _playingController.close();
    _trackController.close();
    _player.dispose();
    _isInitialized = false;
  }
}
