/// Representa um animal disponível para adoção.
class Pet {
  final String id;
  final String ownerId;
  final String name;
  final PetSpecies species;
  final String breed;
  final String age;
  final PetGender gender;
  final PetSize size;
  final PetEnergyLevel energyLevel;
  final PetHealthInfo healthInfo;
  final String description;
  final List<String> photos;
  final String city;
  final String state;
  final PetStatus status;
  final DateTime createdAt;

  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.size,
    required this.energyLevel,
    required this.healthInfo,
    required this.description,
    required this.photos,
    required this.city,
    required this.state,
    required this.status,
    required this.createdAt,
  });

  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    PetSpecies? species,
    String? breed,
    String? age,
    PetGender? gender,
    PetSize? size,
    PetEnergyLevel? energyLevel,
    PetHealthInfo? healthInfo,
    String? description,
    List<String>? photos,
    String? city,
    String? state,
    PetStatus? status,
    DateTime? createdAt,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      size: size ?? this.size,
      energyLevel: energyLevel ?? this.energyLevel,
      healthInfo: healthInfo ?? this.healthInfo,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      city: city ?? this.city,
      state: state ?? this.state,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Informações de saúde do animal.
///
/// Os campos [vaccinated], [neutered] e [dewormed] são nulos quando
/// o responsável não sabe informar (opção "Não sei" na UI).
class PetHealthInfo {
  /// true = sim, false = não, null = não sei
  final bool? vaccinated;

  /// true = sim, false = não, null = não sei
  final bool? neutered;

  /// true = sim, false = não, null = não sei
  final bool? dewormed;

  final List<String> specialNeeds;

  const PetHealthInfo({
    this.vaccinated,
    this.neutered,
    this.dewormed,
    this.specialNeeds = const [],
  });

  PetHealthInfo copyWith({
    bool? vaccinated,
    bool? neutered,
    bool? dewormed,
    List<String>? specialNeeds,
  }) {
    return PetHealthInfo(
      vaccinated: vaccinated ?? this.vaccinated,
      neutered: neutered ?? this.neutered,
      dewormed: dewormed ?? this.dewormed,
      specialNeeds: specialNeeds ?? this.specialNeeds,
    );
  }
}

enum PetSpecies {
  dog('Cachorro'),
  cat('Gato'),
  other('Outro');

  final String label;
  const PetSpecies(this.label);
}

enum PetGender {
  male('Macho'),
  female('Fêmea');

  final String label;
  const PetGender(this.label);
}

enum PetSize {
  small('Pequeno'),
  medium('Médio'),
  large('Grande');

  final String label;
  const PetSize(this.label);
}

enum PetEnergyLevel {
  low('Baixa energia'),
  medium('Energia moderada'),
  high('Alta energia');

  final String label;
  const PetEnergyLevel(this.label);
}

enum PetStatus {
  available('Disponível'),
  inProgress('Em processo'),
  adopted('Adotado');

  final String label;
  const PetStatus(this.label);
}
