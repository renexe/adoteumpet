import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import 'auth_provider.dart';
import 'firebase_providers.dart';

// ── Streams ────────────────────────────────────────────────────────────────────

/// Stream de todos os chats do usuário autenticado.
final userChatsProvider = StreamProvider<List<Chat>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(chatRepositoryProvider).watchChatsForUser(uid);
});

/// Stream das mensagens de um chat específico.
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
});

// ── Operações de escrita ───────────────────────────────────────────────────────

/// Estado das operações de chat.
class ChatWriteState {
  final bool isLoading;
  final String? error;
  final String? createdChatId;

  const ChatWriteState({
    this.isLoading = false,
    this.error,
    this.createdChatId,
  });

  ChatWriteState copyWith({
    bool? isLoading,
    String? error,
    String? createdChatId,
    bool clearError = false,
  }) {
    return ChatWriteState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      createdChatId: createdChatId ?? this.createdChatId,
    );
  }
}

/// Notifier para operações de envio de mensagens e criação de chats.
class ChatWriteNotifier extends Notifier<ChatWriteState> {
  @override
  ChatWriteState build() => const ChatWriteState();

  /// Cria um novo chat ou retorna o ID de um existente.
  Future<String?> createChat({
    required String ownerId,
    required String ownerName,
    required String petId,
    required String petName,
    required String petPhoto,
  }) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return null;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final chatId = await ref.read(chatRepositoryProvider).createChat(
            requesterId: currentUser.uid,
            requesterName: currentUser.displayName,
            ownerId: ownerId,
            ownerName: ownerName,
            petId: petId,
            petName: petName,
            petPhoto: petPhoto,
          );
      state = state.copyWith(isLoading: false, createdChatId: chatId);
      return chatId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao iniciar conversa.',
      );
      return null;
    }
  }

  /// Envia uma mensagem em um chat existente.
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || text.trim().isEmpty) return;

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            chatId: chatId,
            senderId: currentUser.uid,
            text: text,
          );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao enviar mensagem.');
    }
  }

  /// Marca mensagens como lidas ao abrir um chat.
  Future<void> markAsRead(String chatId) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      await ref.read(chatRepositoryProvider).markMessagesAsRead(
            chatId: chatId,
            currentUserId: currentUser.uid,
          );
    } catch (_) {
      // Silencioso — não bloqueia a UX
    }
  }
}

/// Provider de operações de chat.
final chatWriteProvider =
    NotifierProvider<ChatWriteNotifier, ChatWriteState>(ChatWriteNotifier.new);

/// Stream de um chat específico por ID.
final chatByIdProvider =
    StreamProvider.family<Chat?, String>((ref, chatId) {
  return ref
      .watch(chatRepositoryProvider)
      .fetchChat(chatId)
      .asStream();
});
