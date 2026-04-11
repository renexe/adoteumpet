import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/app_exception.dart';

/// Serviço de autenticação usando Firebase Auth.
///
/// Encapsula todas as operações do FirebaseAuth e converte
/// exceções do Firebase em [AppException] tipadas.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  /// Stream do usuário autenticado atual.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuário autenticado atual (pode ser null).
  User? get currentUser => _auth.currentUser;

  /// Faz login com e-mail e senha.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    } catch (e) {
      throw const UnknownException();
    }
  }

  /// Cria uma nova conta com e-mail e senha.
  Future<UserCredential> createUserWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Atualiza o displayName imediatamente após o cadastro
      await credential.user?.updateDisplayName(displayName.trim());
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    } catch (e) {
      throw const UnknownException();
    }
  }

  /// Envia e-mail de redefinição de senha.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    }
  }

  /// Realiza logout.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
