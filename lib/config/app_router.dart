import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/signup_page.dart';
import '../presentation/pages/onboarding/quiz_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/pet_detail/pet_detail_page.dart';
import '../presentation/pages/chat/chat_list_page.dart';
import '../presentation/pages/chat/chat_detail_page.dart';
import '../presentation/pages/profile/profile_page.dart';
import '../presentation/pages/profile/edit_profile_page.dart';
import '../presentation/pages/my_pets/my_pets_page.dart';
import '../presentation/pages/my_pets/add_pet_page.dart';
import '../presentation/providers/auth_provider.dart';
import '../core/widgets/main_scaffold.dart';

/// Nomes das rotas do aplicativo.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String quiz = '/quiz';
  static const String home = '/home';
  static const String petDetail = '/pet/:id';
  static const String chatList = '/chats';
  static const String chatDetail = '/chats/:chatId';
  static const String profile = '/profile';
  static const String myPets = '/my-pets';
  static const String addPet = '/my-pets/add';
  static const String editProfile = '/profile/edit';
}

/// Provider do roteador da aplicação.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;

      // Redireciona para login se não autenticado
      if (!isAuthenticated && !isOnAuthPage) {
        return AppRoutes.login;
      }

      // Redireciona para home se já autenticado e tentando acessar auth
      if (isAuthenticated && isOnAuthPage) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Autenticação
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => const QuizPage(),
      ),

      // Shell com bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.chatList,
            builder: (context, state) => const ChatListPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.myPets,
            builder: (context, state) => const MyPetsPage(),
          ),
        ],
      ),

      // Rotas fora do shell
      GoRoute(
        path: '/pet/:id',
        builder: (context, state) {
          final petId = state.pathParameters['id']!;
          return PetDetailPage(petId: petId);
        },
      ),
      GoRoute(
        path: '/chats/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatDetailPage(chatId: chatId);
        },
      ),
      GoRoute(
        path: AppRoutes.addPet,
        builder: (context, state) => const AddPetPage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
    ],
  );
});
