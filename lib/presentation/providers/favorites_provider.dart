import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pet.dart';
import 'pets_provider.dart';

/// Gerencia a lista de animais favoritos do usuário.
class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]);

  /// Alterna o estado de favorito de um animal.
  void toggleFavorite(String petId) {
    if (state.contains(petId)) {
      state = state.where((id) => id != petId).toList();
    } else {
      state = [...state, petId];
    }
  }

  /// Verifica se um animal está nos favoritos.
  bool isFavorite(String petId) => state.contains(petId);
}

/// Provider global de favoritos.
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>(
  (ref) => FavoritesNotifier(),
);

/// Provider que retorna a lista completa de pets favoritos.
final favoritePetsProvider = Provider<List<Pet>>((ref) {
  final favoriteIds = ref.watch(favoritesProvider);
  final allPets = ref.watch(petsProvider).pets;
  return allPets.where((pet) => favoriteIds.contains(pet.id)).toList();
});
