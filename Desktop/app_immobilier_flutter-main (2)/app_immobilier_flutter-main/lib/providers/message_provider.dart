// providers/message_provider.dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../core/services/api_service.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;
  ApiService? _apiService;

  List<Message> get messages => _messages;
  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize API service (call once)
  Future<void> initialize() async {
    _apiService ??= await ApiService.getInstance();
  }

  Future<ApiService> _ensureApiService() async {
    _apiService ??= await ApiService.getInstance();
    return _apiService!;
  }

  // Get messages with a specific user
  List<Message> getMessagesWithUser(String userId) {
    return _messages
        .where((msg) => msg.senderId == userId || msg.receiverId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Fetch all conversations
  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final api = await _ensureApiService();
      final data = await api.getConversations();

      _conversations = data.map((conv) {
        final lastMsgData = conv['last_message'] as Map<String, dynamic>?;
        Message? lastMessage;

        if (lastMsgData != null) {
          lastMessage = Message(
            id: lastMsgData['id']?.toString() ?? '',
            senderId: lastMsgData['sender_id']?.toString() ?? '',
            senderName: lastMsgData['sender_name'] ?? '',
            receiverId: lastMsgData['receiver_id'].toString(),
            receiverName: lastMsgData['receiver_name'] ?? '',
            content: lastMsgData['content'] ?? '',
            createdAt: DateTime.tryParse(
                    lastMsgData['created_at']?.toString() ?? '') ??
                DateTime.now(),
            isRead: (lastMsgData['is_read'] is bool)
                ? lastMsgData['is_read']
                : (lastMsgData['is_read']?.toString() == 'true'),
          );
        }

        return Conversation(
          id: conv['id']?.toString() ?? '',
          otherUserId: conv['other_user_id']?.toString() ?? '',
          otherUserName: (conv['other_user_name'] ?? 'Unknown').toString(),
          otherUserAvatar: conv['other_user_avatar'],
          lastMessage: lastMessage,
          unreadCount:
              int.tryParse((conv['unread_count'] ?? 0).toString()) ?? 0,
          updatedAt: DateTime.tryParse(conv['updated_at']?.toString() ?? '') ??
              (lastMessage?.createdAt ?? DateTime.now()),
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch conversations error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch messages with a specific user
  Future<void> fetchMessages(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final api = await _ensureApiService();
      final data = await api.getMessages(userId);

      _messages = data
          .map((msg) => Message(
                id: msg['id'].toString(),
                senderId: msg['sender_id'].toString(),
                senderName: msg['sender_name'] ?? 'Unknown',
                senderAvatar: msg['sender_avatar'],
                receiverId: msg['receiver_id'].toString(),
                receiverName: msg['receiver_name'] ?? 'Unknown',
                receiverAvatar: msg['receiver_avatar'],
                content: msg['content'] ?? '',
                createdAt: DateTime.parse(msg['created_at']),
                isRead: msg['is_read'] ?? false,
              ))
          .toList();

      // Mark messages as read
      await markMessagesAsRead(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch messages error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message
  Future<void> sendMessage(Message message) async {
    try {
      // Optimistically add message to UI
      _messages.insert(0, message);

      // Don't send AI chatbot messages to backend (they're client-side only)
      final isChatbotMessage = message.senderId == 'ai_chatbot_assistant' ||
          message.receiverId == 'ai_chatbot_assistant';

      if (!isChatbotMessage) {
        // Call API to send message to real user
        final api = await _ensureApiService();
        await api.sendMessage(
          message.receiverId,
          message.content,
        );
        print('✅ Message sent successfully to user ${message.receiverId}');
      } else {
        print('💬 AI chatbot message (client-side only)');
      }

      // Update conversation list AFTER API success
      _updateConversationList(message);
      notifyListeners();
    } catch (e) {
      print('❌ Send message error: $e');
      _error = e.toString();
      // Remove message if failed
      _messages.removeWhere((m) => m.id == message.id);
      notifyListeners();
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String userId) async {
    try {
      final api = await _ensureApiService();
      await api.markMessagesAsRead(userId);

      // Update local state
      for (var i = 0; i < _messages.length; i++) {
        if (_messages[i].senderId == userId && !_messages[i].isRead) {
          _messages[i] = _messages[i].copyWith(isRead: true);
        }
      }

      // Update conversation unread count
      final convIndex = _conversations.indexWhere(
        (conv) => conv.otherUserId == userId,
      );
      if (convIndex != -1) {
        _conversations[convIndex] = Conversation(
          id: _conversations[convIndex].id,
          otherUserId: _conversations[convIndex].otherUserId,
          otherUserName: _conversations[convIndex].otherUserName,
          otherUserAvatar: _conversations[convIndex].otherUserAvatar,
          lastMessage: _conversations[convIndex].lastMessage,
          unreadCount: 0,
          updatedAt: _conversations[convIndex].updatedAt,
        );
      }

      notifyListeners();
    } catch (e) {
      print('❌ Mark as read error: $e');
      _error = e.toString();
    }
  }

  // Update conversation list after sending message
  void _updateConversationList(Message message) {
    final existingIndex = _conversations.indexWhere(
      (conv) => conv.otherUserId == message.receiverId,
    );

    final updatedConversation = Conversation(
      id: existingIndex != -1 ? _conversations[existingIndex].id : message.id,
      otherUserId: message.receiverId,
      otherUserName: message.receiverName,
      otherUserAvatar: message.receiverAvatar,
      lastMessage: message,
      unreadCount: 0,
      updatedAt: DateTime.now(),
    );

    if (existingIndex != -1) {
      _conversations[existingIndex] = updatedConversation;
    } else {
      _conversations.insert(0, updatedConversation);
    }

    // Sort by updated time
    _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    // Don't call notifyListeners here - caller handles it
  }

  // Get unread message count
  int getUnreadCount() {
    return _conversations.fold(
      0,
      (sum, conv) => sum + conv.unreadCount,
    );
  }
}
