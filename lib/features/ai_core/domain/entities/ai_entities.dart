import 'package:equatable/equatable.dart';

class AIMessage extends Equatable {
  final String id;
  final String content;
  final String role; // 'user' or 'assistant'
  final DateTime timestamp;
  final AIMessageType type;
  final Map<String, dynamic> metadata;

  const AIMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.type = AIMessageType.text,
    this.metadata = const {},
  });

  AIMessage copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? timestamp,
    AIMessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, content, role, timestamp, type, metadata];
}

enum AIMessageType {
  text,
  image,
  audio,
  file,
  command,
}

class AIResponse extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;
  final AIResponseType type;
  final double confidence;
  final Map<String, dynamic> metadata;
  final List<String> suggestions;

  const AIResponse({
    required this.id,
    required this.content,
    required this.timestamp,
    this.type = AIResponseType.text,
    this.confidence = 1.0,
    this.metadata = const {},
    this.suggestions = const [],
  });

  AIResponse copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    AIResponseType? type,
    double? confidence,
    Map<String, dynamic>? metadata,
    List<String>? suggestions,
  }) {
    return AIResponse(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  @override
  List<Object?> get props => [id, content, timestamp, type, confidence, metadata, suggestions];
}

enum AIResponseType {
  text,
  action,
  error,
  thinking,
}

class AIConversationContext extends Equatable {
  final String conversationId;
  final List<AIMessage> history;
  final String userPersonality;
  final String aiPersonality;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> sessionData;

  const AIConversationContext({
    required this.conversationId,
    this.history = const [],
    this.userPersonality = 'neutral',
    this.aiPersonality = 'friendly',
    this.preferences = const {},
    this.sessionData = const {},
  });

  AIConversationContext copyWith({
    String? conversationId,
    List<AIMessage>? history,
    String? userPersonality,
    String? aiPersonality,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? sessionData,
  }) {
    return AIConversationContext(
      conversationId: conversationId ?? this.conversationId,
      history: history ?? this.history,
      userPersonality: userPersonality ?? this.userPersonality,
      aiPersonality: aiPersonality ?? this.aiPersonality,
      preferences: preferences ?? this.preferences,
      sessionData: sessionData ?? this.sessionData,
    );
  }

  @override
  List<Object?> get props => [
        conversationId,
        history,
        userPersonality,
        aiPersonality,
        preferences,
        sessionData,
      ];
}