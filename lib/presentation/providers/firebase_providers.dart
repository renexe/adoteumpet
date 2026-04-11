import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/pet_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';

// ── Instâncias Firebase ────────────────────────────────────────────────────────

/// Provider da instância do FirebaseAuth.
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (_) => FirebaseAuth.instance,
);

/// Provider da instância do FirebaseFirestore.
final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

/// Provider da instância do FirebaseStorage.
final firebaseStorageProvider = Provider<FirebaseStorage>(
  (_) => FirebaseStorage.instance,
);

// ── Serviços ──────────────────────────────────────────────────────────────────

/// Provider do serviço de autenticação.
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseAuthProvider)),
);

/// Provider do serviço de armazenamento.
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(ref.watch(firebaseStorageProvider)),
);

// ── Repositórios ──────────────────────────────────────────────────────────────

/// Provider do repositório de usuários.
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(firestoreProvider)),
);

/// Provider do repositório de pets.
final petRepositoryProvider = Provider<PetRepository>(
  (ref) => PetRepository(ref.watch(firestoreProvider)),
);

/// Provider do repositório de chats.
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(firestoreProvider)),
);
