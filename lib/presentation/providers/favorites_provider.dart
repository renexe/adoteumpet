import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pet.dart';
import 'auth_provider.dart';
import 'firebase_providers.dart';
import 'pets_provider.dart';

// ── Favoritos ──────────────────────────────────────────────────────────────────
//
// Favoritos são armazenados no Firestore como subcoleção do usuário:
//   users/{uid}/favorites/{petId}  →  { petId, savedAt }

/// Notifier de favoritos do usuário.
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // Carrega os favoritos do Firestore ao inicializar
    Future.microtask(_loadFavorites);
    return {};
  }

  Future<void> _loadFavorites() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    try {
      final db = ref.read(firestoreProvider);
      final snap = await db
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .get();
      state = snap.docs.map((d) => d.id).toSet();
    } catch (_) {
      // Silencioso — favoritos são feature auxiliar
    }
  }

  /// Adiciona ou remove um pet dos favoritos.
  Future<void> toggle(String petId) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    final db = ref.read(firestoreProvider);
    final favRef =
        db.collection('users').doc(uid).collection('favorites').doc(petId);

    if (state.contains(petId)) {
      state = {...state}..remove(petId);
      await favRef.delete();
    } else {
      state = {...state, petId};
      await favRef.set({
        'petId': petId,
        'savedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Verifica se um pet está nos favoritos.
  bool isFavorite(String petId) => state.contains(petId);
}

/// Provider global de favoritos.
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// Provider conveniente para checar se um pet específico é favorito.
final isFavoriteProvider = Provider.family<bool, String>((ref, petId) {
  return ref.watch(favoritesProvider).contains(petId);
});

/// Provider que retorna a lista completa de pets favoritos.
final favoritePetsProvider = Provider<AsyncValue<List<Pet>>>((ref) {
  final favoriteIds = ref.watch(favoritesProvider);
  final petsAsync = ref.watch(availablePetsProvider);
  return petsAsync.whenData(
    (pets) => pets.where((p) => favoriteIds.contains(p.id)).toList(),
  );
});
