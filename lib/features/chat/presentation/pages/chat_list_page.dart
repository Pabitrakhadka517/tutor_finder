import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/socket/socket_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/chat_providers.dart';
import 'chat_room_page.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  late final SocketService _socketService;
  DateTime? _lastRealtimeRefresh;

  @override
  void initState() {
    super.initState();
    _socketService = ref.read(socketServiceProvider);
    Future.microtask(() async {
      await ref.read(chatListNotifierProvider.notifier).fetchChats();
      await _initRealtimeSync();
    });
  }

  Future<void> _initRealtimeSync() async {
    await _socketService.connect();
    _socketService.onReceiveMessage((_) => _refreshChatsThrottled());
    _socketService.onMessageSent((_) => _refreshChatsThrottled());
  }

  void _refreshChatsThrottled() {
    final now = DateTime.now();
    if (_lastRealtimeRefresh != null &&
        now.difference(_lastRealtimeRefresh!) <
            const Duration(milliseconds: 400)) {
      return;
    }

    _lastRealtimeRefresh = now;
    ref.read(chatListNotifierProvider.notifier).fetchChats();
  }

  @override
  void dispose() {
    _socketService.off('receive_message');
    _socketService.off('message_sent');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatListNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final currentUser = authState.user;

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
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book a session to start chatting',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(chatListNotifierProvider.notifier).fetchChats();
              },
              child: ListView.builder(
                itemCount: state.chats.length,
                itemBuilder: (context, index) {
                  final chat = state.chats[index];
                  final isCurrentUserTutor = currentUser?.isTutor == true;
                  final isCurrentUserStudent = currentUser?.isStudent == true;

                  final bool showStudent =
                      isCurrentUserTutor ||
                      (!isCurrentUserStudent &&
                          currentUser != null &&
                          chat.tutorId == currentUser.id);

                  final name = showStudent
                      ? (chat.studentName ?? chat.tutorName ?? 'Unknown')
                      : (chat.tutorName ?? chat.studentName ?? 'Unknown');
                  final image = showStudent
                      ? (chat.studentImage ?? chat.tutorImage)
                      : (chat.tutorImage ?? chat.studentImage);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: image != null && image.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                image,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(
                                  name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              name[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: chat.lastMessage != null
                        ? Text(
                            chat.lastMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600),
                          )
                        : const Text(
                            'Start a conversation',
                            style: TextStyle(fontStyle: FontStyle.italic),
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
    final localTime = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(localTime.year, localTime.month, localTime.day);
    final diffDays = today.difference(messageDay).inDays;

    if (diffDays == 0) {
      return DateFormat('hh:mm a').format(localTime);
    } else if (diffDays == 1) {
      return 'Yesterday';
    } else if (diffDays < 7) {
      return DateFormat('EEE').format(localTime);
    } else {
      return DateFormat('MMM d').format(localTime);
    }
  }
}
