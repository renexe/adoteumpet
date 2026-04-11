import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pet.dart';
import 'auth_provider.dart';
import 'firebase_providers.dart';

// ── Streams de pets ────────────────────────────────────────────────────────────

/// Stream de todos os pets disponíveis (feed principal).
final availablePetsProvider = StreamProvider<List<Pet>>((ref) {
  return ref.watch(petRepositoryProvider).watchAvailablePets();
});

/// Stream dos pets do usuário autenticado (Meus Pets).
final myPetsProvider = StreamProvider<List<Pet>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(petRepositoryProvider).watchPetsByOwner(uid);
});

// ── Estado do feed com filtros ─────────────────────────────────────────────────

/// Estado dos filtros ativos no feed.
class PetFeedState {
  final PetSpecies? species;
  final PetSize? size;
  final PetGender? gender;
  final String searchQuery;

  const PetFeedState({
    this.species,
    this.size,
    this.gender,
    this.searchQuery = '',
  });

  bool get hasActiveFilters =>
      species != null ||
      size != null ||
      gender != null ||
      searchQuery.isNotEmpty;

  PetFeedState copyWith({
    PetSpecies? species,
    PetSize? size,
    PetGender? gender,
    String? searchQuery,
    bool clearSpecies = false,
    bool clearSize = false,
    bool clearGender = false,
  }) {
    return PetFeedState(
      species: clearSpecies ? null : species ?? this.species,
      size: clearSize ? null : size ?? this.size,
      gender: clearGender ? null : gender ?? this.gender,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier dos filtros do feed.
class PetFeedNotifier extends Notifier<PetFeedState> {
  @override
  PetFeedState build() => const PetFeedState();

  void setSpecies(PetSpecies? species) =>
      state = state.copyWith(species: species, clearSpecies: species == null);

  void setSize(PetSize? size) =>
      state = state.copyWith(size: size, clearSize: size == null);

  void setGender(PetGender? gender) =>
      state = state.copyWith(gender: gender, clearGender: gender == null);

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void clearFilters() => state = const PetFeedState();
}

/// Provider dos filtros do feed.
final petFeedFilterProvider =
    NotifierProvider<PetFeedNotifier, PetFeedState>(PetFeedNotifier.new);

/// Provider dos pets filtrados para exibição no feed.
final filteredPetsProvider = Provider<AsyncValue<List<Pet>>>((ref) {
  final petsAsync = ref.watch(availablePetsProvider);
  final filters = ref.watch(petFeedFilterProvider);

  return petsAsync.whenData((pets) {
    return pets.where((pet) {
      if (filters.species != null && pet.species != filters.species) {
        return false;
      }
      if (filters.size != null && pet.size != filters.size) return false;
      if (filters.gender != null && pet.gender != filters.gender) return false;
      if (filters.searchQuery.isNotEmpty) {
        final q = filters.searchQuery.toLowerCase();
        if (!pet.name.toLowerCase().contains(q) &&
            !pet.breed.toLowerCase().contains(q) &&
            !pet.city.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  });
});

/// Provider para buscar um pet específico por ID via Firestore.
final petByIdProvider = FutureProvider.family<Pet?, String>((ref, petId) {
  return ref.watch(petRepositoryProvider).fetchPet(petId);
});

// ── Operações de escrita ───────────────────────────────────────────────────────

/// Notifier para operações de criação/edição de pets.
class PetWriteNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Cadastra um novo pet no Firestore.
  Future<String?> createPet(Pet pet) async {
    state = const AsyncValue.loading();
    try {
      final id = await ref.read(petRepositoryProvider).createPet(pet);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Atualiza o status de um pet.
  Future<void> updateStatus(String petId, PetStatus status) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(petRepositoryProvider).updateStatus(petId, status);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Remove um pet.
  Future<void> deletePet(String petId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(petRepositoryProvider).deletePet(petId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider de operações de escrita em pets.
final petWriteProvider =
    NotifierProvider<PetWriteNotifier, AsyncValue<void>>(PetWriteNotifier.new);
