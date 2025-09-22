import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/app_utils.dart';

class SpeechService {
  static SpeechService? _instance;
  late final SpeechToText _speechToText;
  late final FlutterTts _flutterTts;
  
  bool _isListening = false;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentLanguage = 'en-US';
  double _speechRate = 0.8;
  double _speechPitch = 1.0;
  double _speechVolume = 1.0;

  SpeechService._() {
    _speechToText = SpeechToText();
    _flutterTts = FlutterTts();
  }

  static SpeechService get instance {
    _instance ??= SpeechService._();
    return _instance!;
  }

  // Getters
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  String get currentLanguage => _currentLanguage;

  // Initialize speech services
  Future<void> initialize() async {
    try {
      // Request microphone permission
      final micPermission = await Permission.microphone.request();
      if (micPermission != PermissionStatus.granted) {
        throw const PermissionException('Microphone permission required for speech recognition');
      }

      // Initialize Speech-to-Text
      final sttAvailable = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      if (!sttAvailable) {
        throw const ServerException('Speech recognition not available on this device');
      }

      // Initialize Text-to-Speech
      await _initializeTTS();

      _isInitialized = true;
      AppUtils.debugLog('Speech service initialized successfully');
    } catch (e) {
      throw ServerException('Failed to initialize speech service: ${e.toString()}');
    }
  }

  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage(_currentLanguage);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_speechPitch);
    await _flutterTts.setVolume(_speechVolume);

    // Set up TTS callbacks
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      AppUtils.debugLog('TTS started speaking');
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      AppUtils.debugLog('TTS finished speaking');
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      AppUtils.debugError('TTS error: $msg');
    });
  }

  // Speech-to-Text functions
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
    Function(String)? onError,
    String? language,
    Duration? timeout,
  }) async {
    if (!_isInitialized) {
      throw const ServerException('Speech service not initialized');
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      final listenLanguage = language ?? _currentLanguage;
      
      await _speechToText.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          if (result.finalResult) {
            onResult(recognizedWords);
            _isListening = false;
          } else if (onPartialResult != null) {
            onPartialResult(recognizedWords);
          }
        },
        listenFor: timeout ?? const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: onPartialResult != null,
        localeId: listenLanguage,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      _isListening = true;
      AppUtils.debugLog('Started listening for speech');
    } catch (e) {
      _isListening = false;
      final errorMsg = 'Failed to start listening: ${e.toString()}';
      AppUtils.debugError(errorMsg);
      onError?.call(errorMsg);
      throw ServerException(errorMsg);
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
      AppUtils.debugLog('Stopped listening for speech');
    }
  }

  // Text-to-Speech functions
  Future<void> speak(String text, {
    String? language,
    double? rate,
    double? pitch,
    double? volume,
  }) async {
    if (!_isInitialized) {
      throw const ServerException('Speech service not initialized');
    }

    try {
      // Stop any current speech
      if (_isSpeaking) {
        await stop();
      }

      // Set parameters if provided
      if (language != null && language != _currentLanguage) {
        await _flutterTts.setLanguage(language);
      }
      if (rate != null) {
        await _flutterTts.setSpeechRate(rate);
      }
      if (pitch != null) {
        await _flutterTts.setPitch(pitch);
      }
      if (volume != null) {
        await _flutterTts.setVolume(volume);
      }

      // Speak the text
      await _flutterTts.speak(text);
      AppUtils.debugLog('Started speaking: ${text.truncate(50)}');
    } catch (e) {
      _isSpeaking = false;
      throw ServerException('Failed to speak: ${e.toString()}');
    }
  }

  Future<void> pause() async {
    if (_isSpeaking) {
      await _flutterTts.pause();
      AppUtils.debugLog('Paused speaking');
    }
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      AppUtils.debugLog('Stopped speaking');
    }
  }

  // Configuration functions
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    if (_isInitialized) {
      await _flutterTts.setLanguage(language);
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 2.0);
    if (_isInitialized) {
      await _flutterTts.setSpeechRate(_speechRate);
    }
  }

  Future<void> setSpeechPitch(double pitch) async {
    _speechPitch = pitch.clamp(0.5, 2.0);
    if (_isInitialized) {
      await _flutterTts.setPitch(_speechPitch);
    }
  }

  Future<void> setSpeechVolume(double volume) async {
    _speechVolume = volume.clamp(0.0, 1.0);
    if (_isInitialized) {
      await _flutterTts.setVolume(_speechVolume);
    }
  }

  // Get available languages and voices
  Future<List<String>> getAvailableLanguages() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final languages = await _speechToText.locales();
      return languages.map((locale) => locale.localeId).toList();
    } catch (e) {
      AppUtils.debugError('Failed to get available languages: ${e.toString()}');
      return ['en-US']; // Return default language
    }
  }

  Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        return voices.cast<Map<String, String>>();
      }
      return [];
    } catch (e) {
      AppUtils.debugError('Failed to get available voices: ${e.toString()}');
      return [];
    }
  }

  // Wake word detection (simplified implementation)
  Future<void> startWakeWordDetection({
    required List<String> wakeWords,
    required Function(String) onWakeWordDetected,
    Function(String)? onError,
  }) async {
    try {
      await startListening(
        onResult: (result) {
          final lowerResult = result.toLowerCase();
          for (final wakeWord in wakeWords) {
            if (lowerResult.contains(wakeWord.toLowerCase())) {
              onWakeWordDetected(wakeWord);
              return;
            }
          }
          // Continue listening for wake words
          _restartWakeWordDetection(wakeWords, onWakeWordDetected, onError);
        },
        onError: onError,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError?.call('Wake word detection failed: ${e.toString()}');
    }
  }

  Future<void> _restartWakeWordDetection(
    List<String> wakeWords,
    Function(String) onWakeWordDetected,
    Function(String)? onError,
  ) async {
    // Add a small delay before restarting
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_isListening) {
      await startWakeWordDetection(
        wakeWords: wakeWords,
        onWakeWordDetected: onWakeWordDetected,
        onError: onError,
      );
    }
  }

  // Callback handlers
  void _onSpeechStatus(String status) {
    AppUtils.debugLog('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }

  void _onSpeechError(dynamic error) {
    AppUtils.debugError('Speech error: $error');
    _isListening = false;
  }

  // Cleanup
  Future<void> dispose() async {
    await stopListening();
    await stop();
    _isInitialized = false;
    AppUtils.debugLog('Speech service disposed');
  }
}