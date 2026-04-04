import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/chat_message.dart';

/// Dados mock de usuário e chats para desenvolvimento.
abstract final class MockUserData {
  /// Usuário adotante de exemplo.
  static AppUser get adopterUser => AppUser(
        uid: 'user_adopter_001',
        email: 'joao@example.com',
        displayName: 'João Silva',
        userType: UserType.adopter,
        quizAnswers: const QuizAnswers(
          housing: HousingType.largeApartment,
          availableTime: AvailableTime.between2and4h,
          hasChildren: false,
          hasOtherPets: false,
          traits: ['caring', 'patient'],
        ),
        createdAt: DateTime(2026, 3, 1),
      );

  /// Usuário doador de exemplo.
  static AppUser get donorUser => AppUser(
        uid: 'user_donor_001',
        email: 'maria@example.com',
        displayName: 'Maria Santos',
        userType: UserType.donor,
        createdAt: DateTime(2026, 2, 15),
      );

  /// Chats de exemplo para a tela de mensagens.
  static List<Chat> get chats => [
        Chat(
          chatId: 'chat_001',
          adopterId: 'user_adopter_001',
          adopterName: 'João Silva',
          donorId: 'user_donor_001',
          donorName: 'Maria Santos',
          petId: 'pet_001',
          petName: 'Thor',
          petPhoto:
              'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=200',
          messages: [
            ChatMessage(
              messageId: 'msg_001',
              senderId: 'user_adopter_001',
              text: 'Olá! Vi o Thor no aplicativo e me apaixonei. Ele ainda está disponível?',
              timestamp: DateTime(2026, 4, 4, 10, 15),
              read: true,
            ),
            ChatMessage(
              messageId: 'msg_002',
              senderId: 'user_donor_001',
              text: 'Olá, João! Sim, o Thor ainda está disponível. Que bom que você se interessou por ele!',
              timestamp: DateTime(2026, 4, 4, 10, 32),
              read: true,
            ),
            ChatMessage(
              messageId: 'msg_003',
              senderId: 'user_adopter_001',
              text: 'Ótimo! Posso agendar uma visita para conhecê-lo pessoalmente?',
              timestamp: DateTime(2026, 4, 4, 10, 45),
              read: true,
            ),
            ChatMessage(
              messageId: 'msg_004',
              senderId: 'user_donor_001',
              text: 'Claro! Que tal no próximo sábado pela manhã? Posso te passar o endereço.',
              timestamp: DateTime(2026, 4, 4, 11, 00),
              read: false,
            ),
          ],
          lastMessage: 'Claro! Que tal no próximo sábado pela manhã?',
          lastMessageTime: DateTime(2026, 4, 4, 11, 00),
          createdAt: DateTime(2026, 4, 4, 10, 15),
        ),
        Chat(
          chatId: 'chat_002',
          adopterId: 'user_adopter_001',
          adopterName: 'João Silva',
          donorId: 'user_donor_002',
          donorName: 'Carlos Oliveira',
          petId: 'pet_002',
          petName: 'Luna',
          petPhoto:
              'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200',
          messages: [
            ChatMessage(
              messageId: 'msg_005',
              senderId: 'user_adopter_001',
              text: 'Boa tarde! A Luna convive bem com apartamento pequeno?',
              timestamp: DateTime(2026, 4, 3, 15, 20),
              read: true,
            ),
            ChatMessage(
              messageId: 'msg_006',
              senderId: 'user_donor_002',
              text: 'Boa tarde! Sim, ela adora apartamento. É super tranquila e independente.',
              timestamp: DateTime(2026, 4, 3, 16, 05),
              read: true,
            ),
          ],
          lastMessage: 'Sim, ela adora apartamento. É super tranquila.',
          lastMessageTime: DateTime(2026, 4, 3, 16, 05),
          createdAt: DateTime(2026, 4, 3, 15, 20),
        ),
      ];
}
