import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_chatbot_service.dart';
import 'chat_screen.dart';
import '../../widgets/image_with_fallback.dart';
// models/message.dart is used indirectly via MessageProvider

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Fetch conversations after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          final messageProvider =
              Provider.of<MessageProvider>(context, listen: false);

          // Initialize provider
          await messageProvider.initialize();

          // Fetch conversations if authenticated
          if (authProvider.isAuthenticated) {
            messageProvider.fetchConversations();
          }
        }
      });
    }
  }

  String _formatRelative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: Consumer<MessageProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final conversations = provider.conversations;

          return RefreshIndicator(
            onRefresh: provider.fetchConversations,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: conversations.length + 1,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                // First item is AI chatbot
                if (i == 0) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade50,
                          Colors.purple.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade700,
                        child: const Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                        ),
                      ),
                      title: Row(
                        children: [
                          const Text(
                            'Assistant IA Immobilier',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: const Text(
                        'Posez-moi vos questions sur l\'immobilier',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.purple,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(
                              userId: AIChatbotService.botUserId,
                              userName: AIChatbotService.botUserName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                // Regular conversations
                final conv = conversations[i - 1];
                final last = conv.lastMessage;
                final subtitle = last != null ? last.content : '—';
                final time =
                    last != null ? _formatRelative(last.createdAt) : '';

                return ListTile(
                  leading: AvatarWithFallback(
                    imageUrl: conv.otherUserAvatar,
                    radius: 22,
                    initials: conv.otherUserName.isNotEmpty
                        ? conv.otherUserName.substring(0, 1).toUpperCase()
                        : null,
                  ),
                  title: Text(conv.otherUserName),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (time.isNotEmpty)
                        Text(time, style: const TextStyle(fontSize: 12)),
                      if (conv.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conv.unreadCount.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/chat',
                      arguments: {
                        'userId': conv.otherUserId,
                        'userName': conv.otherUserName,
                        'userAvatar': conv.otherUserAvatar,
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
