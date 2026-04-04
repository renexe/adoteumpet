import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_user.dart';
import '../../data/datasources/mock/mock_user_data.dart';

/// Estado de autenticação do aplicativo.
class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// Notifier responsável pelo gerenciamento do estado de autenticação.
///
/// Na versão MVP sem Firebase, simula o fluxo de autenticação
/// com dados mock. A integração real será adicionada na próxima fase.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Simula login com e-mail e senha.
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required bool isDonor,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock: qualquer credencial é aceita
    final user = isDonor ? MockUserData.donorUser : MockUserData.adopterUser;
    state = state.copyWith(user: user, isLoading: false);
  }

  /// Simula cadastro de novo usuário.
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required UserType userType,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await Future.delayed(const Duration(milliseconds: 1000));

    final user = AppUser(
      uid: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: name,
      userType: userType,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(user: user, isLoading: false);
  }

  /// Salva as respostas do quiz de estilo de vida.
  void saveQuizAnswers(QuizAnswers answers) {
    if (state.user == null) return;
    final updatedUser = state.user!.copyWith(quizAnswers: answers);
    state = state.copyWith(user: updatedUser);
  }

  /// Realiza o logout do usuário.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = const AuthState();
  }
}

/// Provider global de autenticação.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Provider conveniente para acessar o usuário atual.
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authProvider).user,
);
