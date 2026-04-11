/// Exceção base do aplicativo.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Erros relacionados à autenticação.
final class AuthException extends AppException {
  const AuthException(super.message);

  factory AuthException.fromFirebaseCode(String code) {
    return switch (code) {
      'user-not-found' =>
        const AuthException('Nenhuma conta encontrada com este e-mail.'),
      'wrong-password' =>
        const AuthException('Senha incorreta. Tente novamente.'),
      'invalid-credential' =>
        const AuthException('E-mail ou senha inválidos.'),
      'email-already-in-use' =>
        const AuthException('Este e-mail já está cadastrado.'),
      'weak-password' =>
        const AuthException('A senha deve ter pelo menos 6 caracteres.'),
      'invalid-email' =>
        const AuthException('Formato de e-mail inválido.'),
      'user-disabled' =>
        const AuthException('Esta conta foi desativada.'),
      'too-many-requests' =>
        const AuthException('Muitas tentativas. Aguarde alguns minutos.'),
      'network-request-failed' =>
        const AuthException('Sem conexão com a internet.'),
      _ => AuthException('Erro de autenticação: $code'),
    };
  }
}

/// Erros relacionados ao banco de dados.
final class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

/// Erros relacionados ao armazenamento de arquivos.
final class StorageException extends AppException {
  const StorageException(super.message);
}

/// Erro genérico não mapeado.
final class UnknownException extends AppException {
  const UnknownException([super.message = 'Ocorreu um erro inesperado.']);
}
