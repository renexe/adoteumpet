/// Representa uma conversa entre o interessado em adotar e o responsável pelo animal.
///
/// [requesterId] é o usuário que demonstrou interesse no animal.
/// [ownerId] é o usuário que cadastrou o animal para doação.
class Chat {
  final String chatId;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final String petId;
  final String petName;
  final String petPhoto;
  final List<ChatMessage> messages;
  final String lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;

  const Chat({
    required this.chatId,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    required this.petId,
    required this.petName,
    required this.petPhoto,
    required this.messages,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
  });
}

/// Representa uma mensagem individual dentro de um chat.
class ChatMessage {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool read;

  const ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.read,
  });
}
