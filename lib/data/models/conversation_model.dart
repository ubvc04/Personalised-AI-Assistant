import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final List<MessageModel> messages;

  const ConversationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.messages = const [],
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  ConversationModel copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    List<MessageModel>? messages,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        createdAt,
        updatedAt,
        isArchived,
        messages,
      ];
}

@JsonSerializable()
class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String content;
  final String senderType; // 'user' or 'ai'
  final DateTime timestamp;
  final String messageType; // 'text', 'image', 'audio', 'file'
  final Map<String, dynamic>? metadata;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.senderType,
    required this.timestamp,
    this.messageType = 'text',
    this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? content,
    String? senderType,
    DateTime? timestamp,
    String? messageType,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      senderType: senderType ?? this.senderType,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        content,
        senderType,
        timestamp,
        messageType,
        metadata,
      ];
}