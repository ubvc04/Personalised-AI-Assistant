import '../databases/database_service.dart';
import '../models/conversation_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/app_utils.dart';

class ConversationRepository {
  final DatabaseService _databaseService;

  ConversationRepository(this._databaseService);

  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      final db = _databaseService.database;
      final conversations = await db.query(
        'conversations',
        where: 'user_id = ? AND is_archived = ?',
        whereArgs: [userId, 0],
        orderBy: 'updated_at DESC',
      );

      final result = <ConversationModel>[];
      for (final conv in conversations) {
        final messages = await getMessages(conv['id'] as String);
        result.add(ConversationModel(
          id: conv['id'] as String,
          userId: conv['user_id'] as String,
          title: conv['title'] as String,
          createdAt: DateTime.fromMillisecondsSinceEpoch(conv['created_at'] as int),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(conv['updated_at'] as int),
          isArchived: (conv['is_archived'] as int) == 1,
          messages: messages,
        ));
      }

      return result;
    } catch (e) {
      throw DatabaseException('Failed to get conversations: ${e.toString()}');
    }
  }

  Future<ConversationModel?> getConversation(String conversationId) async {
    try {
      final db = _databaseService.database;
      final conversations = await db.query(
        'conversations',
        where: 'id = ?',
        whereArgs: [conversationId],
        limit: 1,
      );

      if (conversations.isEmpty) return null;

      final conv = conversations.first;
      final messages = await getMessages(conversationId);

      return ConversationModel(
        id: conv['id'] as String,
        userId: conv['user_id'] as String,
        title: conv['title'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(conv['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(conv['updated_at'] as int),
        isArchived: (conv['is_archived'] as int) == 1,
        messages: messages,
      );
    } catch (e) {
      throw DatabaseException('Failed to get conversation: ${e.toString()}');
    }
  }

  Future<String> createConversation(String userId, String title) async {
    try {
      final db = _databaseService.database;
      final id = AppUtils.generateUniqueId();
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.insert('conversations', {
        'id': id,
        'user_id': userId,
        'title': title,
        'created_at': now,
        'updated_at': now,
        'is_archived': 0,
      });

      return id;
    } catch (e) {
      throw DatabaseException('Failed to create conversation: ${e.toString()}');
    }
  }

  Future<void> updateConversation(ConversationModel conversation) async {
    try {
      final db = _databaseService.database;
      await db.update(
        'conversations',
        {
          'title': conversation.title,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'is_archived': conversation.isArchived ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [conversation.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update conversation: ${e.toString()}');
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final db = _databaseService.database;
      await db.transaction((txn) async {
        // Delete messages first
        await txn.delete(
          'messages',
          where: 'conversation_id = ?',
          whereArgs: [conversationId],
        );
        
        // Delete conversation
        await txn.delete(
          'conversations',
          where: 'id = ?',
          whereArgs: [conversationId],
        );
      });
    } catch (e) {
      throw DatabaseException('Failed to delete conversation: ${e.toString()}');
    }
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final db = _databaseService.database;
      final messages = await db.query(
        'messages',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
        orderBy: 'timestamp ASC',
      );

      return messages.map((message) => MessageModel(
        id: message['id'] as String,
        conversationId: message['conversation_id'] as String,
        content: message['content'] as String,
        senderType: message['sender_type'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(message['timestamp'] as int),
        messageType: message['message_type'] as String? ?? 'text',
        metadata: message['metadata'] != null 
            ? Map<String, dynamic>.from(message['metadata'] as Map)
            : null,
      )).toList();
    } catch (e) {
      throw DatabaseException('Failed to get messages: ${e.toString()}');
    }
  }

  Future<String> addMessage(MessageModel message) async {
    try {
      final db = _databaseService.database;
      
      await db.insert('messages', {
        'id': message.id,
        'conversation_id': message.conversationId,
        'content': message.content,
        'sender_type': message.senderType,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
        'message_type': message.messageType,
        'metadata': message.metadata?.toString(),
      });

      // Update conversation updated_at
      await db.update(
        'conversations',
        {'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [message.conversationId],
      );

      return message.id;
    } catch (e) {
      throw DatabaseException('Failed to add message: ${e.toString()}');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final db = _databaseService.database;
      await db.delete(
        'messages',
        where: 'id = ?',
        whereArgs: [messageId],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete message: ${e.toString()}');
    }
  }

  Future<List<ConversationModel>> searchConversations(String userId, String query) async {
    try {
      final db = _databaseService.database;
      final conversations = await db.rawQuery('''
        SELECT DISTINCT c.* FROM conversations c
        LEFT JOIN messages m ON c.id = m.conversation_id
        WHERE c.user_id = ? AND (
          c.title LIKE ? OR
          m.content LIKE ?
        )
        ORDER BY c.updated_at DESC
      ''', [userId, '%$query%', '%$query%']);

      final result = <ConversationModel>[];
      for (final conv in conversations) {
        final messages = await getMessages(conv['id'] as String);
        result.add(ConversationModel(
          id: conv['id'] as String,
          userId: conv['user_id'] as String,
          title: conv['title'] as String,
          createdAt: DateTime.fromMillisecondsSinceEpoch(conv['created_at'] as int),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(conv['updated_at'] as int),
          isArchived: (conv['is_archived'] as int) == 1,
          messages: messages,
        ));
      }

      return result;
    } catch (e) {
      throw DatabaseException('Failed to search conversations: ${e.toString()}');
    }
  }

  Future<void> archiveConversation(String conversationId) async {
    try {
      final db = _databaseService.database;
      await db.update(
        'conversations',
        {
          'is_archived': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [conversationId],
      );
    } catch (e) {
      throw DatabaseException('Failed to archive conversation: ${e.toString()}');
    }
  }

  Future<void> unarchiveConversation(String conversationId) async {
    try {
      final db = _databaseService.database;
      await db.update(
        'conversations',
        {
          'is_archived': 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [conversationId],
      );
    } catch (e) {
      throw DatabaseException('Failed to unarchive conversation: ${e.toString()}');
    }
  }
}