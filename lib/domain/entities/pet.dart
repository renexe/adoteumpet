/// Representa um animal disponível para adoção.
class Pet {
  final String id;
  final String donorId;
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
    required this.donorId,
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
    String? donorId,
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
      donorId: donorId ?? this.donorId,
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
class PetHealthInfo {
  final bool vaccinated;
  final bool neutered;
  final bool dewormed;
  final List<String> specialNeeds;

  const PetHealthInfo({
    required this.vaccinated,
    required this.neutered,
    required this.dewormed,
    this.specialNeeds = const [],
  });
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
