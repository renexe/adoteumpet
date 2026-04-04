import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pet.dart';
import '../../data/datasources/mock/mock_pets_data.dart';

/// Estado do feed de animais.
class PetsState {
  final List<Pet> pets;
  final bool isLoading;
  final String? error;
  final PetSpecies? speciesFilter;
  final PetSize? sizeFilter;
  final PetGender? genderFilter;

  const PetsState({
    this.pets = const [],
    this.isLoading = false,
    this.error,
    this.speciesFilter,
    this.sizeFilter,
    this.genderFilter,
  });

  List<Pet> get filteredPets {
    return pets.where((pet) {
      if (speciesFilter != null && pet.species != speciesFilter) return false;
      if (sizeFilter != null && pet.size != sizeFilter) return false;
      if (genderFilter != null && pet.gender != genderFilter) return false;
      return pet.status == PetStatus.available;
    }).toList();
  }

  PetsState copyWith({
    List<Pet>? pets,
    bool? isLoading,
    String? error,
    PetSpecies? speciesFilter,
    PetSize? sizeFilter,
    PetGender? genderFilter,
    bool clearSpeciesFilter = false,
    bool clearSizeFilter = false,
    bool clearGenderFilter = false,
  }) {
    return PetsState(
      pets: pets ?? this.pets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      speciesFilter: clearSpeciesFilter ? null : speciesFilter ?? this.speciesFilter,
      sizeFilter: clearSizeFilter ? null : sizeFilter ?? this.sizeFilter,
      genderFilter: clearGenderFilter ? null : genderFilter ?? this.genderFilter,
    );
  }
}

/// Notifier responsável pelo gerenciamento do feed de animais.
class PetsNotifier extends StateNotifier<PetsState> {
  PetsNotifier() : super(const PetsState()) {
    loadPets();
  }

  /// Carrega a lista de animais disponíveis.
  Future<void> loadPets() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(pets: MockPetsData.pets, isLoading: false);
  }

  /// Aplica filtro por espécie.
  void filterBySpecies(PetSpecies? species) {
    if (species == null) {
      state = state.copyWith(clearSpeciesFilter: true);
    } else {
      state = state.copyWith(speciesFilter: species);
    }
  }

  /// Aplica filtro por porte.
  void filterBySize(PetSize? size) {
    if (size == null) {
      state = state.copyWith(clearSizeFilter: true);
    } else {
      state = state.copyWith(sizeFilter: size);
    }
  }

  /// Aplica filtro por gênero.
  void filterByGender(PetGender? gender) {
    if (gender == null) {
      state = state.copyWith(clearGenderFilter: true);
    } else {
      state = state.copyWith(genderFilter: gender);
    }
  }

  /// Remove todos os filtros ativos.
  void clearFilters() {
    state = state.copyWith(
      clearSpeciesFilter: true,
      clearSizeFilter: true,
      clearGenderFilter: true,
    );
  }
}

/// Provider global de pets.
final petsProvider = StateNotifierProvider<PetsNotifier, PetsState>(
  (ref) => PetsNotifier(),
);

/// Provider para um pet específico por ID.
final petByIdProvider = Provider.family<Pet?, String>((ref, petId) {
  final pets = ref.watch(petsProvider).pets;
  try {
    return pets.firstWhere((p) => p.id == petId);
  } catch (_) {
    return null;
  }
});
