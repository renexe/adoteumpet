import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/chat_message.dart';

/// Repositório de chats — streams em tempo real e envio de mensagens.
///
/// Estrutura no Firestore:
/// ```
/// chats/{chatId}
///   ├── requesterId, ownerId, petId, petName, petPhoto, ...
///   └── messages/{messageId}
///         ├── senderId, text, timestamp, read
/// ```
class ChatRepository {
  ChatRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('chats');

  // ── Streams ────────────────────────────────────────────────────────────────

  /// Stream de todos os chats em que o usuário participa (como requester ou owner).
  Stream<List<Chat>> watchChatsForUser(String userId) {
    // Firestore não suporta OR em queries, então fazemos duas queries e mesclamos.
    // Na fase Firebase real, use collection group queries ou Cloud Functions.
    return _col
        .where('requesterId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snap) async {
      final asRequester = snap.docs
          .map((d) => _chatFromMap(d.id, d.data(), []))
          .toList();

      // Busca também chats onde o usuário é owner
      final ownerSnap = await _col
          .where('ownerId', isEqualTo: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();
      final asOwner = ownerSnap.docs
          .map((d) => _chatFromMap(d.id, d.data(), []))
          .toList();

      // Mescla e remove duplicatas
      final all = {...asRequester, ...asOwner}.toList();
      all.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return all;
    });
  }

  /// Stream das mensagens de um chat específico em tempo real.
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _col
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => _messageFromMap(d.id, d.data())).toList());
  }

  // ── Leitura pontual ────────────────────────────────────────────────────────

  /// Busca metadados de um chat pelo ID.
  Future<Chat?> fetchChat(String chatId) async {
    try {
      final doc = await _col.doc(chatId).get();
      if (!doc.exists || doc.data() == null) return null;
      return _chatFromMap(doc.id, doc.data()!, []);
    } catch (e) {
      throw DatabaseException('Erro ao buscar chat: $e');
    }
  }

  // ── Escrita ────────────────────────────────────────────────────────────────

  /// Cria um novo chat e retorna o ID gerado.
  Future<String> createChat({
    required String requesterId,
    required String requesterName,
    required String ownerId,
    required String ownerName,
    required String petId,
    required String petName,
    required String petPhoto,
  }) async {
    try {
      // Verifica se já existe um chat para este par usuário+pet
      final existing = await _col
          .where('requesterId', isEqualTo: requesterId)
          .where('petId', isEqualTo: petId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return existing.docs.first.id;

      final ref = await _col.add({
        'requesterId': requesterId,
        'requesterName': requesterName,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'petId': petId,
        'petName': petName,
        'petPhoto': petPhoto,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      throw DatabaseException('Erro ao criar chat: $e');
    }
  }

  /// Envia uma mensagem em um chat existente.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      final batch = _db.batch();
      final msgRef = _col.doc(chatId).collection('messages').doc();

      // Adiciona a mensagem
      batch.set(msgRef, {
        'senderId': senderId,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Atualiza o resumo do chat
      batch.update(_col.doc(chatId), {
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw DatabaseException('Erro ao enviar mensagem: $e');
    }
  }

  /// Marca todas as mensagens não lidas de um remetente como lidas.
  Future<void> markMessagesAsRead({
    required String chatId,
    required String currentUserId,
  }) async {
    try {
      final unread = await _col
          .doc(chatId)
          .collection('messages')
          .where('read', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      if (unread.docs.isEmpty) return;

      final batch = _db.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Erro ao marcar mensagens como lidas: $e');
    }
  }

  // ── Serialização ───────────────────────────────────────────────────────────

  Chat _chatFromMap(
      String id, Map<String, dynamic> map, List<ChatMessage> messages) {
    return Chat(
      chatId: id,
      requesterId: map['requesterId'] as String? ?? '',
      requesterName: map['requesterName'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      petId: map['petId'] as String? ?? '',
      petName: map['petName'] as String? ?? '',
      petPhoto: map['petPhoto'] as String? ?? '',
      messages: messages,
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageTime:
          (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ChatMessage _messageFromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      messageId: id,
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp:
          (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: map['read'] as bool? ?? false,
    );
  }
}
