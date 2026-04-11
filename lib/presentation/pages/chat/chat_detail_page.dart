import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../presentation/providers/chat_provider.dart';
import '../../../presentation/providers/auth_provider.dart';


class ChatDetailPage extends ConsumerStatefulWidget {
  final String chatId;

  const ChatDetailPage({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Marca mensagens como lidas ao abrir o chat
    Future.microtask(
      () => ref.read(chatWriteProvider.notifier).markAsRead(widget.chatId),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await ref.read(chatWriteProvider.notifier).sendMessage(
          chatId: widget.chatId,
          text: text,
        );

    // Rola para o final após enviar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatByIdProvider(widget.chatId));
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final user = ref.watch(currentUserProvider);

    return chatAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Erro ao carregar conversa')),
      ),
      data: (chat) {
        if (chat == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Conversa não encontrada')),
          );
        }
        return _buildScaffold(context, chat, messagesAsync, user?.uid ?? '');
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    Chat chat,
    AsyncValue<List<ChatMessage>> messagesAsync,
    String currentUserId,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: SizedBox(
                width: 40,
                height: 40,
                child: CachedNetworkImage(
                  imageUrl: chat.petPhoto,
                  fit: BoxFit.cover,
                  errorWidget: (ctx, url, err) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.pets,
                        color: AppColors.textHint, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.petName,
                    style: AppTextStyles.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currentUserId == chat.requesterId
                        ? 'Responsável: ${chat.ownerName}'
                        : 'Interessado: ${chat.requesterName}',
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          // Lista de mensagens em tempo real
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (messages) => messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            'Inicie a conversa!',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xs),
                          Text(
                            'Apresente-se e tire suas dúvidas.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppDimensions.md),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUserId;
                        return _MessageBubble(
                          message: message.text,
                          timestamp: message.timestamp,
                          isMe: isMe,
                        );
                      },
                    ),
            ),
          ),

          // Input de mensagem
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.sm,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: AppTextStyles.bodyMedium,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Digite uma mensagem...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
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
  final String message;
  final DateTime timestamp;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.timestamp,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppDimensions.radiusMd),
            topRight: const Radius.circular(AppDimensions.radiusMd),
            bottomLeft: Radius.circular(isMe ? AppDimensions.radiusMd : 4),
            bottomRight: Radius.circular(isMe ? 4 : AppDimensions.radiusMd),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('HH:mm').format(timestamp),
              style: AppTextStyles.bodySmall.copyWith(
                color: isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textHint,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
