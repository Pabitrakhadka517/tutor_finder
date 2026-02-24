import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/chat_providers.dart';
import 'chat_room_page.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(chatListNotifierProvider.notifier).fetchChats(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(chatListNotifierProvider.notifier)
                            .fetchChats(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : state.chats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Book a session to start chatting',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref
                            .read(chatListNotifierProvider.notifier)
                            .fetchChats();
                      },
                      child: ListView.builder(
                        itemCount: state.chats.length,
                        itemBuilder: (context, index) {
                          final chat = state.chats[index];
                          // Show the other person's name
                          final name = chat.tutorName ?? chat.studentName ?? 'Unknown';
                          final image = chat.tutorImage ?? chat.studentImage;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              backgroundImage: image != null
                                  ? NetworkImage(image)
                                  : null,
                              child: image == null
                                  ? Text(
                                      name[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: chat.lastMessage != null
                                ? Text(
                                    chat.lastMessage!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  )
                                : const Text(
                                    'Start a conversation',
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                            trailing: chat.lastMessageAt != null
                                ? Text(
                                    _formatTime(chat.lastMessageAt!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  )
                                : null,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomPage(
                                    chatId: chat.id,
                                    recipientName: name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return DateFormat('hh:mm a').format(dateTime);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
