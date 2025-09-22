import '../../domain/entities/ai_entities.dart';

enum AIResponseType {
  text,
  voice,
  mixed,
  error,
}

class AIMessageModel extends AIMessage {
  const AIMessageModel({
    required super.id,
    required super.content,
    required super.role,
    required super.timestamp,
    super.type,
    super.metadata,
  });

  factory AIMessageModel.fromJson(Map<String, dynamic> json) {
    return AIMessageModel(
      id: json['id'],
      content: json['content'],
      role: json['role'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'metadata': metadata,
    };
  }

  factory AIMessageModel.fromEntity(AIMessage entity) {
    return AIMessageModel(
      id: entity.id,
      content: entity.content,
      role: entity.role,
      timestamp: entity.timestamp,
      type: entity.type,
      metadata: entity.metadata,
    );
  }

  AIMessage toEntity() {
    return AIMessage(
      id: id,
      content: content,
      role: role,
      timestamp: timestamp,
      type: type,
      metadata: metadata,
    );
  }
}

class AIResponseModel extends AIResponse {
  const AIResponseModel({
    required super.id,
    required super.content,
    required super.timestamp,
    super.type,
    super.confidence,
    super.metadata,
    super.suggestions,
  });

  factory AIResponseModel.fromJson(Map<String, dynamic> json) {
    return AIResponseModel(
      id: json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      confidence: json['confidence']?.toDouble(),
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      suggestions: json['suggestions'] != null ? List<String>.from(json['suggestions']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'confidence': confidence,
      'metadata': metadata,
      'suggestions': suggestions,
    };
  }

  factory AIResponseModel.fromEntity(AIResponse entity) {
    return AIResponseModel(
      id: entity.id,
      content: entity.content,
      timestamp: entity.timestamp,
      type: entity.type,
      confidence: entity.confidence,
      metadata: entity.metadata,
      suggestions: entity.suggestions,
    );
  }

  AIResponse toEntity() {
    return AIResponse(
      id: id,
      content: content,
      timestamp: timestamp,
      type: type,
      confidence: confidence,
      metadata: metadata,
      suggestions: suggestions,
    );
  }
}

class AIConversationContextModel extends AIConversationContext {
  const AIConversationContextModel({
    required super.conversationId,
    super.history,
    super.userPersonality,
    super.aiPersonality,
    super.preferences,
    super.sessionData,
  });

  factory AIConversationContextModel.fromJson(Map<String, dynamic> json) {
    return AIConversationContextModel(
      conversationId: json['conversationId'],
      history: json['history'] != null 
        ? (json['history'] as List).map((e) => AIMessageModel.fromJson(e)).toList()
        : null,
      userPersonality: json['userPersonality'],
      aiPersonality: json['aiPersonality'],
      preferences: json['preferences'] != null ? Map<String, dynamic>.from(json['preferences']) : null,
      sessionData: json['sessionData'] != null ? Map<String, dynamic>.from(json['sessionData']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'history': history?.map((e) => (e as AIMessageModel).toJson()).toList(),
      'userPersonality': userPersonality,
      'aiPersonality': aiPersonality,
      'preferences': preferences,
      'sessionData': sessionData,
    };
  }

  factory AIConversationContextModel.fromEntity(AIConversationContext entity) {
    return AIConversationContextModel(
      conversationId: entity.conversationId,
      history: entity.history.map((msg) => AIMessageModel.fromEntity(msg)).toList(),
      userPersonality: entity.userPersonality,
      aiPersonality: entity.aiPersonality,
      preferences: entity.preferences,
      sessionData: entity.sessionData,
    );
  }

  AIConversationContext toEntity() {
    return AIConversationContext(
      conversationId: conversationId,
      history: history.map((msg) => (msg as AIMessageModel).toEntity()).toList(),
      userPersonality: userPersonality,
      aiPersonality: aiPersonality,
      preferences: preferences,
      sessionData: sessionData,
    );
  }
}