import '../entities/ai_entities.dart';
import '../../../../core/utils/typedefs.dart';

abstract class AIRepository {
  ResultFuture<AIResponse> sendMessage({
    required String message,
    required AIConversationContext context,
  });

  ResultFuture<AIResponse> processVoiceCommand({
    required String command,
    required AIConversationContext context,
  });

  ResultFuture<AIResponse> analyzeImage({
    required String imagePath,
    required String prompt,
    required AIConversationContext context,
  });

  ResultFuture<List<String>> getSuggestions({
    required String input,
    required AIConversationContext context,
  });

  ResultFuture<String> generateTitle({
    required List<AIMessage> messages,
  });

  ResultFuture<AIResponse> executeAction({
    required String action,
    required Map<String, dynamic> parameters,
    required AIConversationContext context,
  });

  ResultFuture<List<AIMessage>> getConversationHistory({
    required String conversationId,
    int? limit,
  });

  ResultVoid clearConversationHistory({
    required String conversationId,
  });

  ResultFuture<Map<String, dynamic>> getPersonalityTraits({
    required String personalityType,
  });

  ResultFuture<List<String>> getAvailablePersonalities();

  ResultFuture<String> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  });

  ResultFuture<String> summarizeText({
    required String text,
    int? maxLength,
  });
}