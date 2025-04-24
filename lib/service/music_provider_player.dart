import 'package:deezerapim1sir/musique/music.dart';
import 'package:flutter/material.dart';

class MusicPlayerProvider with ChangeNotifier {
  Music? _currentMusic;
  bool _isPlaying = false;

  Music? get currentMusic => _currentMusic;
  bool get isPlaying => _isPlaying;

  void playMusic(Music music) {
    _currentMusic = music;
    _isPlaying = true;
    notifyListeners();
  }

  void pauseMusic() {
    _isPlaying = false;
    notifyListeners();
  }

  void togglePlayPause(Music music) {
    if (_currentMusic == music && _isPlaying) {
      pauseMusic();
    } else {
      playMusic(music);
    }
  }
}