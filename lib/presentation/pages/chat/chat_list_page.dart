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

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mensagens'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: chatsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text('Erro ao carregar mensagens: $e'),
        ),
        data: (chats) => chats.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      'Nenhuma conversa ainda',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Demonstre interesse em um pet para\niniciar uma conversa',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: chats.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return _ChatTile(
                    chat: chat,
                    currentUserId: user?.uid ?? '',
                  );
                },
              ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Chat chat;
  final String currentUserId;

  const _ChatTile({required this.chat, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final lastMsg = chat.messages.isNotEmpty ? chat.messages.last : null;
    final hasUnread = lastMsg != null &&
        !lastMsg.read &&
        lastMsg.senderId != currentUserId;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: SizedBox(
          width: AppDimensions.avatarLg,
          height: AppDimensions.avatarLg,
          child: CachedNetworkImage(
            imageUrl: chat.petPhoto,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.pets, color: AppColors.textHint),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.pets, color: AppColors.textHint),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.petName,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight:
                    hasUnread ? FontWeight.w700 : FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(chat.lastMessageTime),
            style: AppTextStyles.bodySmall.copyWith(
              color: hasUnread ? AppColors.primary : AppColors.textHint,
              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: hasUnread
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight:
                    hasUnread ? FontWeight.w600 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (hasUnread)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(left: AppDimensions.xs),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () => context.push('/chats/${chat.chatId}'),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }
}
