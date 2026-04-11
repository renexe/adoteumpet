import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_exception.dart';
import '../../data/datasources/mock/mock_user_data.dart';
import '../../domain/entities/app_user.dart';
import 'firebase_providers.dart';

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
/// Usa Firebase Auth quando disponível. O fluxo de autenticação é:
/// 1. [signInWithEmail] / [signUpWithEmail] → Firebase Auth
/// 2. Após autenticação, busca/cria o perfil no Firestore via [UserRepository]
/// 3. O estado [AuthState.user] é atualizado com o [AppUser] completo
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Escuta mudanças de autenticação do Firebase em tempo real
    ref.listen(firebaseAuthStateProvider, (_, next) {
      next.whenData((fbUser) async {
        if (fbUser == null) {
          state = const AuthState();
          return;
        }
        await _loadUserProfile(fbUser);
      });
    });
    return const AuthState();
  }

  /// Carrega o perfil completo do Firestore após autenticação.
  Future<void> _loadUserProfile(fb.User fbUser) async {
    try {
      final repo = ref.read(userRepositoryProvider);
      var appUser = await repo.fetchUser(fbUser.uid);

      if (appUser == null) {
        // Primeira vez — cria o perfil com dados do Firebase Auth
        appUser = AppUser(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName ?? 'Usuário',
          profilePicture: fbUser.photoURL,
          createdAt: DateTime.now(),
        );
        await repo.saveUser(appUser);
      }

      state = state.copyWith(user: appUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao carregar perfil.',
        isLoading: false,
      );
    }
  }

  /// Faz login com e-mail e senha via Firebase Auth.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(email: email, password: password);
      // O listener firebaseAuthStateProvider cuida do restante
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado. Tente novamente.',
      );
    }
  }

  /// Cria uma nova conta via Firebase Auth.
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.createUserWithEmail(
        email: email,
        password: password,
        displayName: name,
      );
      // O listener firebaseAuthStateProvider cuida do restante
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado. Tente novamente.',
      );
    }
  }

  /// Atualiza o perfil do usuário autenticado no Firestore.
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? profilePicture,
    UserLocation? location,
    UserContact? contact,
    UserPrivacy? privacy,
  }) async {
    final current = state.user;
    if (current == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = current.copyWith(
        displayName: displayName,
        bio: bio,
        profilePicture: profilePicture,
        location: location,
        contact: contact,
        privacy: privacy,
      );
      await ref.read(userRepositoryProvider).saveUser(updated);
      state = state.copyWith(user: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao salvar perfil.',
      );
    }
  }

  /// Realiza o logout.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await ref.read(authServiceProvider).signOut();
    state = const AuthState();
  }
}

/// Provider global de autenticação.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Provider conveniente para acessar o usuário atual.
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authProvider).user,
);

/// Provider que escuta o stream do Firebase Auth.
///
/// Usado internamente pelo [AuthNotifier] para reagir a mudanças de sessão.
final firebaseAuthStateProvider = StreamProvider<fb.User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

/// Provider de dados mock — usado apenas em testes e desenvolvimento sem Firebase.
final mockUserProvider = Provider<AppUser>((_) => MockUserData.mockUser);
