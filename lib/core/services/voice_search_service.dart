import '/exports.dart';

class VoiceSearchService extends GetxService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  // State variables
  final isListening = false.obs;
  final isAvailable = false.obs;
  final confidenceLevel = 0.0.obs;
  final recognizedText = ''.obs;
  final isInitialized = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeSpeechToText();
    await _initializeTextToSpeech();
  }

  // Initialize Speech to Text
  Future<void> _initializeSpeechToText() async {
    try {
      bool available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      isAvailable.value = available;
      isInitialized.value = true;

      if (!available) {
        AppHelpers.logError('Speech recognition not available');
      }
    } catch (e) {
      AppHelpers.logError('Failed to initialize speech recognition: $e');
      isAvailable.value = false;
      isInitialized.value = true;
    }
  }

  // Initialize Text to Speech
  Future<void> _initializeTextToSpeech() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.8);
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      AppHelpers.logError('Failed to initialize text to speech: $e');
    }
  }

  // Start voice search
  Future<String?> startVoiceSearch() async {
    if (!isAvailable.value) {
      AppHelpers.showSnackBar('Voice search not available', isError: true);
      return null;
    }

    try {
      isListening.value = true;
      recognizedText.value = '';
      confidenceLevel.value = 0.0;

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        onSoundLevelChange: _onSoundLevelChange,
      );

      // Wait for listening to complete
      while (isListening.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      return recognizedText.value.isNotEmpty ? recognizedText.value : null;
    } catch (e) {
      AppHelpers.showSnackBar('Voice search failed', isError: true);
      isListening.value = false;
      return null;
    }
  }

  // Stop voice search
  Future<void> stopVoiceSearch() async {
    if (isListening.value) {
      await _speechToText.stop();
      isListening.value = false;
    }
  }

  // Speak text
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      AppHelpers.logError('Failed to speak text: $e');
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      AppHelpers.logError('Failed to stop speaking: $e');
    }
  }

  // Voice search with processing
  Future<VoiceSearchResult> searchWithVoice() async {
    try {
      final searchText = await startVoiceSearch();

      if (searchText == null || searchText.isEmpty) {
        return VoiceSearchResult(
          success: false,
          text: '',
          confidence: 0.0,
          error: 'No speech detected',
        );
      }

      // Process the search text
      final processedQuery = _processSearchQuery(searchText);

      return VoiceSearchResult(
        success: true,
        text: processedQuery,
        confidence: confidenceLevel.value,
        originalText: searchText,
      );
    } catch (e) {
      return VoiceSearchResult(
        success: false,
        text: '',
        confidence: 0.0,
        error: e.toString(),
      );
    }
  }

  // Process search query
  String _processSearchQuery(String query) {
    // Clean up the query
    String processed = query.toLowerCase().trim();

    // Handle common voice search patterns
    processed = _handleVoiceCommands(processed);
    processed = _correctCommonMistakes(processed);
    processed = _handleQuantities(processed);

    return processed;
  }

  // Handle voice commands
  String _handleVoiceCommands(String query) {
    // Handle "search for" patterns
    if (query.startsWith('search for ')) {
      return query.substring(11);
    }

    if (query.startsWith('find ')) {
      return query.substring(5);
    }

    if (query.startsWith('look for ')) {
      return query.substring(9);
    }

    if (query.startsWith('i need ')) {
      return query.substring(7);
    }

    if (query.startsWith('i want ')) {
      return query.substring(7);
    }

    return query;
  }

  // Correct common speech recognition mistakes
  String _correctCommonMistakes(String query) {
    final corrections = {
      'tomatos': 'tomatoes',
      'potatos': 'potatoes',
      'bannana': 'banana',
      'brocoli': 'broccoli',
      'cabage': 'cabbage',
      'carrit': 'carrot',
      'carrits': 'carrots',
      'aple': 'apple',
      'aples': 'apples',
      'orang': 'orange',
      'orangs': 'oranges',
      'chiken': 'chicken',
      'bred': 'bread',
      'chees': 'cheese',
      'mlik': 'milk',
      'yogurt': 'yogurt',
      'rise': 'rice',
      'pasta': 'pasta',
      'beens': 'beans',
      'lemmon': 'lemon',
      'lemmons': 'lemons',
    };

    String corrected = query;
    corrections.forEach((mistake, correction) {
      corrected = corrected.replaceAll(mistake, correction);
    });

    return corrected;
  }

  // Handle quantity expressions
  String _handleQuantities(String query) {
    final quantityPatterns = {
      r'\bone\b': '1',
      r'\btwo\b': '2',
      r'\bthree\b': '3',
      r'\bfour\b': '4',
      r'\bfive\b': '5',
      r'\bsix\b': '6',
      r'\bseven\b': '7',
      r'\beight\b': '8',
      r'\bnine\b': '9',
      r'\bten\b': '10',
      r'\ba dozen\b': '12',
      r'\bdozen\b': '12',
      r'\ba pound of\b': '1 pound',
      r'\btwo pounds of\b': '2 pounds',
      r'\ba kilogram of\b': '1 kg',
      r'\ba liter of\b': '1 liter',
      r'\ba bottle of\b': '1 bottle',
      r'\ba pack of\b': '1 pack',
      r'\ba bag of\b': '1 bag',
    };

    String processed = query;
    quantityPatterns.forEach((pattern, replacement) {
      processed = processed.replaceAll(RegExp(pattern, caseSensitive: false), replacement);
    });

    return processed;
  }

  // Check if speech recognition is supported
  Future<bool> isSpeechRecognitionSupported() async {
    try {
      return await _speechToText.hasPermission;
    } catch (e) {
      return false;
    }
  }

  // Event handlers
  void _onSpeechStatus(String status) {
    switch (status) {
      case 'listening':
        isListening.value = true;
        break;
      case 'notListening':
      case 'done':
        isListening.value = false;
        break;
    }
  }

  void _onSpeechError(dynamic error) {
    isListening.value = false;
    AppHelpers.logError('Speech recognition error: $error');
    AppHelpers.showSnackBar('Voice search failed. Please try again.', isError: true);
  }

  void _onSpeechResult(dynamic result) {
    try {
      if (result?.recognizedWords != null) {
        recognizedText.value = result.recognizedWords;
        confidenceLevel.value = result.confidence ?? 0.0;
      }
    } catch (e) {
      AppHelpers.logError('Error processing speech result: $e');
    }
  }

  void _onSoundLevelChange(double level) {
    // You can use this to show sound level indicators
  }
}

// Voice search result model
class VoiceSearchResult {
  final bool success;
  final String text;
  final double confidence;
  final String? originalText;
  final String? error;

  VoiceSearchResult({
    required this.success,
    required this.text,
    required this.confidence,
    this.originalText,
    this.error,
  });
}
