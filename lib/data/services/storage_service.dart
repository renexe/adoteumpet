import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/errors/app_exception.dart';

/// Serviço de armazenamento de arquivos usando Firebase Storage.
///
/// Estrutura de pastas no Storage:
/// ```
/// users/{uid}/profile.jpg          ← foto de perfil
/// pets/{petId}/photo_0.jpg         ← fotos do pet (índice 0..n)
/// ```
class StorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;

  // ── Perfil ─────────────────────────────────────────────────────────────────

  /// Faz upload da foto de perfil e retorna a URL pública.
  Future<String> uploadProfilePhoto({
    required String uid,
    required File file,
  }) async {
    try {
      final ref = _storage.ref('users/$uid/profile.jpg');
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException('Erro ao enviar foto de perfil: ${e.message}');
    }
  }

  /// Remove a foto de perfil do usuário.
  Future<void> deleteProfilePhoto(String uid) async {
    try {
      await _storage.ref('users/$uid/profile.jpg').delete();
    } on FirebaseException catch (e) {
      // Ignora erro se o arquivo não existir
      if (e.code != 'object-not-found') {
        throw StorageException('Erro ao remover foto de perfil: ${e.message}');
      }
    }
  }

  // ── Pets ───────────────────────────────────────────────────────────────────

  /// Faz upload de uma foto de pet e retorna a URL pública.
  ///
  /// [index] é a posição da foto na lista (0, 1, 2...).
  Future<String> uploadPetPhoto({
    required String petId,
    required File file,
    required int index,
  }) async {
    try {
      final ref = _storage.ref('pets/$petId/photo_$index.jpg');
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException('Erro ao enviar foto do pet: ${e.message}');
    }
  }

  /// Faz upload de múltiplas fotos de um pet e retorna as URLs.
  Future<List<String>> uploadPetPhotos({
    required String petId,
    required List<File> files,
  }) async {
    final urls = <String>[];
    for (var i = 0; i < files.length; i++) {
      final url = await uploadPetPhoto(
        petId: petId,
        file: files[i],
        index: i,
      );
      urls.add(url);
    }
    return urls;
  }

  /// Remove todas as fotos de um pet.
  Future<void> deletePetPhotos(String petId) async {
    try {
      final ref = _storage.ref('pets/$petId');
      final list = await ref.listAll();
      for (final item in list.items) {
        await item.delete();
      }
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        throw StorageException('Erro ao remover fotos do pet: ${e.message}');
      }
    }
  }
}
