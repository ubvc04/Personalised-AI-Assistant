import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart' as app_exceptions;
import '../../../../core/utils/app_utils.dart';
import '../models/ai_models.dart';

abstract class AIRemoteDataSource {
  Future<AIResponseModel> sendMessage({
    required String message,
    required AIConversationContextModel context,
  });

  Future<AIResponseModel> processVoiceCommand({
    required String command,
    required AIConversationContextModel context,
  });

  Future<AIResponseModel> analyzeImage({
    required String imagePath,
    required String prompt,
    required AIConversationContextModel context,
  });

  Future<List<String>> getSuggestions({
    required String input,
    required AIConversationContextModel context,
  });

  Future<String> generateTitle({
    required List<AIMessageModel> messages,
  });

  Future<String> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  });

  Future<String> summarizeText({
    required String text,
    int? maxLength,
  });
}

class AIRemoteDataSourceImpl implements AIRemoteDataSource {
  late final GenerativeModel _model;
  late final SpeechToText _speechToText;
  late final FlutterTts _flutterTts;

  AIRemoteDataSourceImpl() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 32,
        topP: 1,
        maxOutputTokens: 2048,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
    
    _speechToText = SpeechToText();
    _flutterTts = FlutterTts();
    _initializeTTS();
  }

  void _initializeTTS() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
  }

  @override
  Future<AIResponseModel> sendMessage({
    required String message,
    required AIConversationContextModel context,
  }) async {
    try {
      final prompt = _buildPrompt(message, context);
      final response = await _model.generateContent([Content.text(prompt)]);
      
      if (response.text == null) {
        throw const ServerException('Failed to generate response');
      }

      return AIResponseModel(
        id: AppUtils.generateUniqueId(),
        content: response.text!,
        timestamp: DateTime.now(),
        type: AIResponseType.text,
        confidence: _calculateConfidence(response),
        metadata: {
          'model': 'gemini-1.5-flash',
          'tokens_used': response.usageMetadata?.totalTokenCount ?? 0,
        },
        suggestions: _extractSuggestions(response.text!),
      );
    } catch (e) {
      throw app_exceptions.ServerException('Failed to send message: ${e.toString()}');
    }
  }

  @override
  Future<AIResponseModel> processVoiceCommand({
    required String command,
    required AIConversationContextModel context,
  }) async {
    try {
      final enhancedPrompt = '''
        The user gave this voice command: "$command"
        
        Please process this as a voice command and provide an appropriate response.
        If it's an action command (like "open settings", "play music", "call someone"), 
        respond with the action details in this format:
        ACTION: [action_name]
        PARAMETERS: [json_parameters]
        RESPONSE: [user_friendly_response]
        
        ${_getPersonalityContext(context.aiPersonality)}
      ''';

      final response = await _model.generateContent([Content.text(enhancedPrompt)]);
      
      if (response.text == null) {
        throw const ServerException('Failed to process voice command');
      }

      final content = response.text!;
      final type = content.contains('ACTION:') 
          ? AIResponseType.action 
          : AIResponseType.text;

      return AIResponseModel(
        id: AppUtils.generateUniqueId(),
        content: content,
        timestamp: DateTime.now(),
        type: type,
        confidence: _calculateConfidence(response),
        metadata: {
          'model': 'gemini-1.5-flash',
          'voice_command': command,
          'tokens_used': response.usageMetadata?.totalTokenCount ?? 0,
        },
        suggestions: _extractSuggestions(content),
      );
    } catch (e) {
      throw app_exceptions.ServerException('Failed to process voice command: ${e.toString()}');
    }
  }

  @override
  Future<AIResponseModel> analyzeImage({
    required String imagePath,
    required String prompt,
    required AIConversationContextModel context,
  }) async {
    try {
      // For now, we'll simulate image analysis
      // In a real implementation, you would upload the image to Gemini
      const response = '''
        I can see the image you've shared. However, image analysis functionality 
        is currently being implemented. Please describe what you'd like me to help 
        you with regarding this image, and I'll do my best to assist you based on 
        your description.
      ''';

      return AIResponseModel(
        id: AppUtils.generateUniqueId(),
        content: response,
        timestamp: DateTime.now(),
        type: AIResponseType.text,
        confidence: 0.8,
        metadata: {
          'model': 'gemini-1.5-flash',
          'image_path': imagePath,
          'prompt': prompt,
        },
        suggestions: [
          'Describe the image to me',
          'What would you like to know about this image?',
          'Tell me what you see in the image',
        ],
      );
    } catch (e) {
      throw app_exceptions.ServerException('Failed to analyze image: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getSuggestions({
    required String input,
    required AIConversationContextModel context,
  }) async {
    try {
      final prompt = '''
        Based on the user input: "$input"
        And conversation context with ${context.history.length} previous messages,
        
        Provide 3-5 helpful follow-up suggestions or questions that would be relevant.
        Return only the suggestions, one per line, without numbering or bullets.
        Keep them concise and actionable.
        
        ${_getPersonalityContext(context.aiPersonality)}
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      
      if (response.text == null) {
        return _getDefaultSuggestions();
      }

      return response.text!
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(5)
          .toList();
    } catch (e) {
      AppUtils.debugError('Failed to get suggestions: ${e.toString()}');
      return _getDefaultSuggestions();
    }
  }

  @override
  Future<String> generateTitle({
    required List<AIMessageModel> messages,
  }) async {
    try {
      if (messages.isEmpty) return 'New Conversation';
      
      final conversationText = messages
          .take(5) // Use first 5 messages
          .map((msg) => '${msg.role}: ${msg.content}')
          .join('\n');

      final prompt = '''
        Based on this conversation:
        $conversationText
        
        Generate a short, descriptive title (3-6 words) that captures the main topic.
        Return only the title, nothing else.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      
      return response.text?.trim() ?? 'New Conversation';
    } catch (e) {
      AppUtils.debugError('Failed to generate title: ${e.toString()}');
      return 'New Conversation';
    }
  }

  @override
  Future<String> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    try {
      final prompt = '''
        Translate the following text to $targetLanguage:
        "$text"
        
        Return only the translation, nothing else.
        ${sourceLanguage != null ? 'Source language: $sourceLanguage' : ''}
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      
      return response.text?.trim() ?? text;
    } catch (e) {
      throw app_exceptions.ServerException('Failed to translate text: ${e.toString()}');
    }
  }

  @override
  Future<String> summarizeText({
    required String text,
    int? maxLength,
  }) async {
    try {
      final prompt = '''
        Summarize the following text${maxLength != null ? ' in about $maxLength words' : ''}:
        "$text"
        
        Provide a clear, concise summary that captures the key points.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      
      return response.text?.trim() ?? text;
    } catch (e) {
      throw app_exceptions.ServerException('Failed to summarize text: ${e.toString()}');
    }
  }

  String _buildPrompt(String message, AIConversationContextModel context) {
    final historyContext = context.history.isNotEmpty
        ? 'Previous conversation:\n${_formatHistory(context.history)}\n\n'
        : '';

    return '''
      $historyContext
      User message: $message
      
      ${_getPersonalityContext(context.aiPersonality)}
      
      Please respond naturally and helpfully. If the user is asking you to perform an action 
      (like setting a reminder, opening an app, or making a call), include action details 
      in your response using this format:
      
      ACTION: [action_name]
      PARAMETERS: [json_parameters]
      RESPONSE: [user_friendly_response]
      
      Otherwise, just provide a natural conversational response.
    ''';
  }

  String _formatHistory(List<AIMessageModel> history) {
    return history
        .takeLast(10) // Limit context to last 10 messages
        .map((msg) => '${msg.role}: ${msg.content}')
        .join('\n');
  }

  String _getPersonalityContext(String personality) {
    switch (personality.toLowerCase()) {
      case 'friendly':
        return 'Respond in a warm, friendly, and approachable manner. Be encouraging and positive.';
      case 'professional':
        return 'Respond in a professional, courteous, and efficient manner. Be concise and helpful.';
      case 'casual':
        return 'Respond in a relaxed, casual, and conversational manner. Use informal language.';
      case 'energetic':
        return 'Respond with enthusiasm and energy. Be upbeat and motivating.';
      case 'calm':
        return 'Respond in a calm, patient, and measured manner. Be soothing and thoughtful.';
      default:
        return 'Respond naturally and helpfully.';
    }
  }

  double _calculateConfidence(GenerateContentResponse response) {
    // Simple confidence calculation based on response length and safety ratings
    if (response.text == null || response.text!.isEmpty) return 0.0;
    
    // Basic confidence score - in a real implementation, you might use
    // more sophisticated metrics
    double confidence = 0.8;
    
    if (response.text!.length < 20) confidence -= 0.2;
    if (response.text!.length > 500) confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }

  List<String> _extractSuggestions(String response) {
    // Extract potential follow-up questions or suggestions from the response
    // This is a simple implementation - you could make this more sophisticated
    final suggestions = <String>[];
    
    if (response.contains('?')) {
      suggestions.add('Tell me more about that');
    }
    
    if (response.toLowerCase().contains('help')) {
      suggestions.add('What else can you help me with?');
    }
    
    suggestions.addAll([
      'Can you explain that differently?',
      'Show me an example',
      'What\'s next?',
    ]);
    
    return suggestions.take(3).toList();
  }

  List<String> _getDefaultSuggestions() {
    return [
      'How can I help you today?',
      'Tell me more about what you need',
      'What would you like to know?',
      'Is there anything else I can assist with?',
    ];
  }
}
