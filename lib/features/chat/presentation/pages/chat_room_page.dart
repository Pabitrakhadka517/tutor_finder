import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/socket/socket_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/chat_providers.dart';
import '../../domain/entities/chat_entities.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  final String chatId;
  final String recipientName;

  const ChatRoomPage({
    super.key,
    required this.chatId,
    required this.recipientName,
  });

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _currentUserId;
  late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _socketService = ref.read(socketServiceProvider);
    _loadCurrentUser();
    Future.microtask(() {
      ref
          .read(chatMessagesNotifierProvider.notifier)
          .fetchMessages(widget.chatId);
      _initSocket();
    });
  }

  Future<void> _loadCurrentUser() async {
    // Try auth state first (most reliable)
    final authUser = ref.read(authNotifierProvider).user;
    if (authUser != null) {
      if (mounted) setState(() => _currentUserId = authUser.id);
      return;
    }

    // Fallback: try both storage keys (auth stores as 'user_id',
    // StorageService stores as 'userId')
    const storage = FlutterSecureStorage();
    var userId = await storage.read(key: 'user_id');
    userId ??= await storage.read(key: 'userId');
    if (mounted) setState(() => _currentUserId = userId);
  }

  /// Connect socket, join room, and listen for incoming messages
  Future<void> _initSocket() async {
    await _socketService.connect();
    _socketService.joinRoom(widget.chatId);
    _socketService.markRead(widget.chatId);

    _socketService.onReceiveMessage((data) {
      if (!mounted) return;
      if (data is Map<String, dynamic>) {
        // Only add if it's for this chat room
        final roomId =
            data['chatRoom']?.toString() ?? data['chatId']?.toString();
        if (roomId == widget.chatId) {
          ref
              .read(chatMessagesNotifierProvider.notifier)
              .addIncomingMessage(data);
          // Mark as read since we're viewing this chat
          _socketService.markRead(widget.chatId);
        }
      }
    });

    _socketService.onMessageSent((data) {
      // Message delivery confirmation from server - could update UI if needed
      debugPrint('SocketService: Message sent confirmed');
    });

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // Remove socket listeners for this room when leaving
    _socketService.off('receive_message');
    _socketService.off('message_sent');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Send via REST for reliability (message appears in state via notifier)
    ref
        .read(chatMessagesNotifierProvider.notifier)
        .sendMessage(widget.chatId, text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatMessagesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderId == _currentUserId;
                      return _MessageBubble(message: msg, isMe: isMe);
                    },
                  ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    child: IconButton(
                      icon: state.isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                      onPressed: state.isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.createdAt),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
