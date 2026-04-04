import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/datasources/mock/mock_user_data.dart';

/// Gerencia o estado das conversas do usuário.
class ChatNotifier extends Notifier<List<Chat>> {
  @override
  List<Chat> build() {
    // Carrega os chats mock assim que o provider é criado
    Future.microtask(_loadChats);
    return [];
  }

  Future<void> _loadChats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    state = MockUserData.chats;
  }

  /// Envia uma nova mensagem em um chat existente.
  void sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) {
    final newMessage = ChatMessage(
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
      read: false,
    );

    state = state.map((chat) {
      if (chat.chatId != chatId) return chat;
      return Chat(
        chatId: chat.chatId,
        adopterId: chat.adopterId,
        adopterName: chat.adopterName,
        donorId: chat.donorId,
        donorName: chat.donorName,
        petId: chat.petId,
        petName: chat.petName,
        petPhoto: chat.petPhoto,
        messages: [...chat.messages, newMessage],
        lastMessage: text,
        lastMessageTime: newMessage.timestamp,
        createdAt: chat.createdAt,
      );
    }).toList();
  }

  /// Cria um novo chat ao demonstrar interesse em um animal.
  void createChat({
    required String adopterId,
    required String adopterName,
    required String donorId,
    required String donorName,
    required String petId,
    required String petName,
    required String petPhoto,
  }) {
    // Verifica se já existe um chat para este pet
    final exists =
        state.any((c) => c.petId == petId && c.adopterId == adopterId);
    if (exists) return;

    final newChat = Chat(
      chatId: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      adopterId: adopterId,
      adopterName: adopterName,
      donorId: donorId,
      donorName: donorName,
      petId: petId,
      petName: petName,
      petPhoto: petPhoto,
      messages: [],
      lastMessage: 'Conversa iniciada',
      lastMessageTime: DateTime.now(),
      createdAt: DateTime.now(),
    );

    state = [...state, newChat];
  }
}

/// Provider global de chats.
final chatProvider = NotifierProvider<ChatNotifier, List<Chat>>(
  ChatNotifier.new,
);

/// Provider para um chat específico por ID.
final chatByIdProvider = Provider.family<Chat?, String>((ref, chatId) {
  final chats = ref.watch(chatProvider);
  try {
    return chats.firstWhere((c) => c.chatId == chatId);
  } catch (_) {
    return null;
  }
});
