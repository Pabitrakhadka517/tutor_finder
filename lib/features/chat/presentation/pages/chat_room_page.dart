import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/socket/socket_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/chat_entities.dart';
import '../providers/chat_providers.dart';

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
  String? _editingMessageId;
  String? _selectedFilePath;
  String? _selectedFileName;
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
    final authUser = ref.read(authNotifierProvider).user;
    if (authUser != null) {
      if (mounted) {
        setState(() => _currentUserId = authUser.id);
      }
      return;
    }

    const storage = FlutterSecureStorage();
    var userId = await storage.read(key: 'user_id');
    userId ??= await storage.read(key: 'userId');
    if (mounted) {
      setState(() => _currentUserId = userId);
    }
  }

  Future<void> _initSocket() async {
    await _socketService.connect();
    _socketService.joinRoom(widget.chatId);
    _socketService.markRead(widget.chatId);

    _socketService.onReceiveMessage((data) {
      if (!mounted || data is! Map<String, dynamic>) return;
      final roomId = data['chatRoom']?.toString() ?? data['chatId']?.toString();
      if (roomId != widget.chatId) return;

      ref.read(chatMessagesNotifierProvider.notifier).addIncomingMessage(data);
      ref.read(chatListNotifierProvider.notifier).fetchChats();
      _socketService.markRead(widget.chatId);
    });

    _socketService.onMessageEdited((data) {
      if (!mounted || data is! Map<String, dynamic>) return;
      final roomId = data['chatRoom']?.toString();
      if (roomId != null && roomId != widget.chatId) return;

      ref.read(chatMessagesNotifierProvider.notifier).applyEditedMessage(data);
    });

    _socketService.onMessageDeleted((data) {
      if (!mounted || data is! Map<String, dynamic>) return;
      final roomId = data['chatRoom']?.toString();
      if (roomId != null && roomId != widget.chatId) return;

      ref.read(chatMessagesNotifierProvider.notifier).applyDeletedMessage(data);
    });
  }

  @override
  void dispose() {
    _socketService.off('receive_message');
    _socketService.off('message_edited');
    _socketService.off('message_deleted');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.perm_media),
              title: const Text('Photo or Video'),
              onTap: () => Navigator.of(context).pop('media'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Document (PDF, DOC, etc.)'),
              onTap: () => Navigator.of(context).pop('doc'),
            ),
          ],
        ),
      ),
    );

    if (action == null) return;

    FilePickerResult? result;
    if (action == 'media') {
      result = await FilePicker.platform.pickFiles(type: FileType.media);
    } else {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'ppt',
          'pptx',
          'txt',
          'zip',
          'xls',
          'xlsx',
          'csv',
        ],
      );
    }

    final file = result?.files.single;
    if (file == null || file.path == null) return;

    setState(() {
      _selectedFilePath = file.path;
      _selectedFileName = file.name;
    });
  }

  Future<void> _submitMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedFilePath == null) return;

    if (_editingMessageId != null) {
      final success = await ref
          .read(chatMessagesNotifierProvider.notifier)
          .editMessage(_editingMessageId!, text);

      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to edit message')));
      }

      _cancelEdit();
      return;
    }

    await ref
        .read(chatMessagesNotifierProvider.notifier)
        .sendMessage(
          widget.chatId,
          content: text.isEmpty ? null : text,
          filePath: _selectedFilePath,
        );

    ref.read(chatListNotifierProvider.notifier).fetchChats();

    if (!mounted) return;

    _messageController.clear();
    setState(() {
      _selectedFilePath = null;
      _selectedFileName = null;
    });
  }

  void _startEdit(MessageEntity message) {
    setState(() {
      _editingMessageId = message.id;
      _messageController.text = message.message;
      _selectedFilePath = null;
      _selectedFileName = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingMessageId = null;
      _messageController.clear();
    });
  }

  Future<void> _deleteMessage(MessageEntity message) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('This message will be removed for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final success = await ref
        .read(chatMessagesNotifierProvider.notifier)
        .deleteMessage(message.id);

    if (!mounted || success) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Failed to delete message')));
  }

  Future<void> _showMessageActions(MessageEntity message, bool isMe) async {
    if (!isMe || message.isDeleted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.messageType == ChatMessageType.text)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit message'),
                onTap: () {
                  Navigator.of(context).pop();
                  _startEdit(message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete message'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteMessage(message);
              },
            ),
          ],
        ),
      ),
    );
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
                      final message = state.messages[index];
                      final isMe = message.senderId == _currentUserId;
                      return _MessageBubble(
                        message: message,
                        isMe: isMe,
                        onLongPress: () => _showMessageActions(message, isMe),
                      );
                    },
                  ),
          ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_editingMessageId != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 16),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Editing message')),
                          IconButton(
                            onPressed: _cancelEdit,
                            icon: const Icon(Icons.close, size: 18),
                            splashRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  if (_selectedFileName != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFileName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilePath = null;
                                _selectedFileName = null;
                              });
                            },
                            icon: const Icon(Icons.close, size: 18),
                            splashRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: state.isSending || _editingMessageId != null
                            ? null
                            : _pickAttachment,
                        icon: Icon(
                          Icons.attach_file,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: _editingMessageId != null
                                ? 'Edit your message...'
                                : 'Type a message...',
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
                          onSubmitted: (_) => _submitMessage(),
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
                              : Icon(
                                  _editingMessageId != null
                                      ? Icons.check
                                      : Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          onPressed: state.isSending ? null : _submitMessage,
                        ),
                      ),
                    ],
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
  final VoidCallback onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.onLongPress,
  });

  Future<void> _openAttachment(BuildContext context) async {
    final fileUrl = message.fileUrl;
    if (fileUrl == null || fileUrl.isEmpty) return;

    final uri = Uri.tryParse(fileUrl);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open file')));
    }
  }

  IconData _fileIcon() {
    final name = (message.fileName ?? message.fileUrl ?? '').toLowerCase();
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (name.endsWith('.doc') || name.endsWith('.docx')) {
      return Icons.description;
    }
    if (name.endsWith('.xls') ||
        name.endsWith('.xlsx') ||
        name.endsWith('.csv')) {
      return Icons.table_chart;
    }
    if (name.endsWith('.ppt') || name.endsWith('.pptx')) return Icons.slideshow;
    if (name.endsWith('.zip') || name.endsWith('.rar')) return Icons.archive;
    if (name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.avi') ||
        name.endsWith('.mkv') ||
        name.endsWith('.webm')) {
      return Icons.movie;
    }
    return Icons.insert_drive_file;
  }

  Widget _buildMessageContent(BuildContext context) {
    if (message.isDeleted) {
      return Text(
        'This message was deleted',
        style: TextStyle(
          color: isMe ? Colors.white70 : Colors.grey.shade700,
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      );
    }

    if (message.messageType == ChatMessageType.image &&
        message.fileUrl != null &&
        message.fileUrl!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              message.fileUrl!,
              height: 180,
              width: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                width: 220,
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          if (message.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ],
        ],
      );
    }

    if ((message.messageType == ChatMessageType.file ||
            message.fileUrl != null) &&
        (message.fileUrl ?? '').isNotEmpty) {
      return InkWell(
        onTap: () => _openAttachment(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isMe ? Colors.white24 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_fileIcon(), size: 20, color: isMe ? Colors.white : null),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.fileName ?? 'Open attachment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Text(
      message.message,
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black87,
        fontSize: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
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
              _buildMessageContent(context),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isEdited && !message.isDeleted)
                    Text(
                      'edited',
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey.shade500,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  if (message.isEdited && !message.isDeleted)
                    const SizedBox(width: 6),
                  Text(
                    DateFormat('hh:mm a').format(message.createdAt.toLocal()),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
