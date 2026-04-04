/// Representa uma conversa entre adotante e doador.
class Chat {
  final String chatId;
  final String adopterId;
  final String adopterName;
  final String donorId;
  final String donorName;
  final String petId;
  final String petName;
  final String petPhoto;
  final List<ChatMessage> messages;
  final String lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;

  const Chat({
    required this.chatId,
    required this.adopterId,
    required this.adopterName,
    required this.donorId,
    required this.donorName,
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
