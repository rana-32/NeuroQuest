import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  
  late AudioPlayer _audioPlayer;
  bool _soundEnabled = true;
  bool _assetsAvailable = true;
  
  // Maps of asset existence status to avoid repeated checks
  final Map<String, bool> _assetExists = {};
  
  // Maps for tracking valid playable assets
  final Map<String, bool> _validAssets = {};
  
  SoundManager._internal() {
    _initAudio();
  }
  
  // Initialize audio player
  Future<void> _initAudio() async {
    _audioPlayer = AudioPlayer();
    await loadSoundPreference();
    
    // Check if any required sounds exist to set the overall flag
    _assetsAvailable = await _checkAssetExists('sounds/click.mp3');
    
    // Pre-check all sound assets
    await _validateSoundAssets();
  }
  
  // Pre-check and validate all sound assets
  Future<void> _validateSoundAssets() async {
    try {
      final soundFiles = [
        'sounds/click.mp3',
        'sounds/correct.mp3',
        'sounds/wrong.mp3',
        'sounds/intro.mp3',
        'sounds/victory.mp3',
        'sounds/background.mp3',
      ];
      
      for (final soundPath in soundFiles) {
        try {
          // Just check existence, don't actually try to play
          final exists = await _checkAssetExists(soundPath);
          // Mark as potentially valid if exists, but we'll know for sure only on first play
          _validAssets[soundPath] = exists;
        } catch (e) {
          _validAssets[soundPath] = false;
          debugPrint('Sound asset validation failed for $soundPath: $e');
        }
      }
    } catch (e) {
      debugPrint('Error validating sound assets: $e');
    }
  }
  
  // Check if an asset exists
  Future<bool> _checkAssetExists(String assetPath) async {
    if (_assetExists.containsKey(assetPath)) {
      return _assetExists[assetPath]!;
    }
    
    try {
      await rootBundle.load('assets/$assetPath');
      _assetExists[assetPath] = true;
      return true;
    } catch (e) {
      _assetExists[assetPath] = false;
      debugPrint('Asset not found: assets/$assetPath');
      return false;
    }
  }
  
  // Load sound preference
  Future<void> loadSoundPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    } catch (e) {
      debugPrint('Error loading sound preference: $e');
    }
  }
  
  // Save sound preference
  Future<void> saveSoundPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _soundEnabled);
    } catch (e) {
      debugPrint('Error saving sound preference: $e');
    }
  }
  
  // Get sound status
  bool get isSoundEnabled => _soundEnabled;
  
  // Toggle sound
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await saveSoundPreference();
  }
  
  // Safe play method
  Future<void> _safePlay(String soundPath) async {
    // Don't try to play if sound is disabled or no assets available
    if (!_soundEnabled || !_assetsAvailable) return;
    
    // Check if this asset was previously marked as invalid
    if (_validAssets.containsKey(soundPath) && _validAssets[soundPath] == false) {
      debugPrint('Skipping invalid sound asset: $soundPath');
      return;
    }
    
    // Check if this specific asset exists
    if (!await _checkAssetExists(soundPath)) return;
    
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(soundPath));
      // Mark as valid if successful
      _validAssets[soundPath] = true;
    } catch (e) {
      // Mark as invalid for future reference
      _validAssets[soundPath] = false;
      debugPrint('Error playing sound $soundPath: $e');
    }
  }
  
  // Play correct answer sound
  Future<void> playCorrectSound() async {
    await _safePlay('sounds/correct.mp3');
  }
  
  // Play wrong answer sound
  Future<void> playWrongSound() async {
    await _safePlay('sounds/wrong.mp3');
  }
  
  // Play victory sound
  Future<void> playVictorySound() async {
    await _safePlay('sounds/victory.mp3');
  }
  
  // Play click sound
  Future<void> playClickSound() async {
    await _safePlay('sounds/click.mp3');
  }
  
  // Play background music
  Future<void> playBackgroundMusic() async {
    // Don't try to play if sound is disabled or no assets available
    if (!_soundEnabled || !_assetsAvailable) return;
    
    // Check if this asset was previously marked as invalid
    if (_validAssets.containsKey('sounds/background.mp3') && 
        _validAssets['sounds/background.mp3'] == false) {
      debugPrint('Skipping invalid background music');
      return;
    }
    
    // Check if this specific asset exists
    if (!await _checkAssetExists('sounds/background.mp3')) return;
    
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/background.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.3); // Lower volume for background music
      
      // Mark as valid if successful
      _validAssets['sounds/background.mp3'] = true;
    } catch (e) {
      // Mark as invalid for future reference
      _validAssets['sounds/background.mp3'] = false;
      debugPrint('Error playing background music: $e');
    }
  }
  
  // Stop all sounds
  Future<void> stopAll() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping sounds: $e');
    }
  }
  
  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
  
  // Play intro sound
  void playIntroSound() async {
    await _safePlay('sounds/intro.mp3');
  }
} 