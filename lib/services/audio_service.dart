import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  late AudioPlayer _audioPlayer;

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
  }

  factory AudioService() {
    return _instance;
  }

  Future<void> playAudio(String assetPath) async {
    try {
      // Normalize asset path for AssetSource: it expects the path relative to
      // the `assets/` directory (e.g. 'audios/vocabulaire/bonjou.mp3').
      String path = assetPath;
      if (path.startsWith('assets/')) {
        path = path.substring('assets/'.length);
      } else if (path.startsWith('/assets/')) {
        path = path.substring('/assets/'.length);
      }
      await _audioPlayer.play(
        AssetSource(path),
        volume: 1.0,
      );
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<Duration?> getDuration() async {
    return await _audioPlayer.getDuration();
  }

  Stream<Duration> getPositionStream() {
    return _audioPlayer.onPositionChanged;
  }

  Stream<PlayerState> getPlayerStateStream() {
    return _audioPlayer.onPlayerStateChanged;
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

