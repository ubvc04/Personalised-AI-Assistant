import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/ai_entities.dart';

part 'ai_models.g.dart';

@JsonSerializable()
class AIMessageModel extends AIMessage {
  const AIMessageModel({
    required super.id,
    required super.content,
    required super.role,
    required super.timestamp,
    super.type,
    super.metadata,
  });

  factory AIMessageModel.fromJson(Map<String, dynamic> json) =>
      _$AIMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$AIMessageModelToJson(this);

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

@JsonSerializable()
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

  factory AIResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AIResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AIResponseModelToJson(this);

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

@JsonSerializable()
class AIConversationContextModel extends AIConversationContext {
  const AIConversationContextModel({
    required super.conversationId,
    super.history,
    super.userPersonality,
    super.aiPersonality,
    super.preferences,
    super.sessionData,
  });

  factory AIConversationContextModel.fromJson(Map<String, dynamic> json) =>
      _$AIConversationContextModelFromJson(json);

  Map<String, dynamic> toJson() => _$AIConversationContextModelToJson(this);

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