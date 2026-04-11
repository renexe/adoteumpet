import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/pet.dart';

/// Repositório de pets — CRUD e streams no Firestore.
///
/// Coleção: `pets/{petId}`
class PetRepository {
  PetRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('pets');

  // ── Streams ────────────────────────────────────────────────────────────────

  /// Stream de todos os pets disponíveis, ordenados por data de criação.
  Stream<List<Pet>> watchAvailablePets() {
    return _col
        .where('status', isEqualTo: PetStatus.available.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _fromMap(d.id, d.data())).toList());
  }

  /// Stream dos pets de um usuário específico.
  Stream<List<Pet>> watchPetsByOwner(String ownerId) {
    return _col
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _fromMap(d.id, d.data())).toList());
  }

  // ── Leitura pontual ────────────────────────────────────────────────────────

  /// Busca um pet pelo ID.
  Future<Pet?> fetchPet(String petId) async {
    try {
      final doc = await _col.doc(petId).get();
      if (!doc.exists || doc.data() == null) return null;
      return _fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw DatabaseException('Erro ao buscar pet: $e');
    }
  }

  // ── Escrita ────────────────────────────────────────────────────────────────

  /// Cria um novo pet e retorna o ID gerado.
  Future<String> createPet(Pet pet) async {
    try {
      final ref = await _col.add(_toMap(pet));
      return ref.id;
    } catch (e) {
      throw DatabaseException('Erro ao cadastrar pet: $e');
    }
  }

  /// Atualiza campos de um pet existente.
  Future<void> updatePet(String petId, Map<String, dynamic> fields) async {
    try {
      await _col.doc(petId).update(fields);
    } catch (e) {
      throw DatabaseException('Erro ao atualizar pet: $e');
    }
  }

  /// Atualiza o status do pet (disponível, em processo, adotado).
  Future<void> updateStatus(String petId, PetStatus status) async {
    await updatePet(petId, {'status': status.name});
  }

  /// Remove um pet (soft delete via status ou hard delete).
  Future<void> deletePet(String petId) async {
    try {
      await _col.doc(petId).delete();
    } catch (e) {
      throw DatabaseException('Erro ao remover pet: $e');
    }
  }

  // ── Serialização ───────────────────────────────────────────────────────────

  Pet _fromMap(String id, Map<String, dynamic> map) {
    final healthMap = map['healthInfo'] as Map<String, dynamic>? ?? {};
    final healthInfo = PetHealthInfo(
      vaccinated: healthMap['vaccinated'] as bool?,
      neutered: healthMap['neutered'] as bool?,
      dewormed: healthMap['dewormed'] as bool?,
      specialNeeds: List<String>.from(healthMap['specialNeeds'] ?? []),
    );

    return Pet(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      species: PetSpecies.values.firstWhere(
        (e) => e.name == map['species'],
        orElse: () => PetSpecies.dog,
      ),
      breed: map['breed'] as String? ?? '',
      age: map['age'] as String? ?? '',
      gender: PetGender.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => PetGender.male,
      ),
      size: PetSize.values.firstWhere(
        (e) => e.name == map['size'],
        orElse: () => PetSize.medium,
      ),
      energyLevel: PetEnergyLevel.values.firstWhere(
        (e) => e.name == map['energyLevel'],
        orElse: () => PetEnergyLevel.medium,
      ),
      healthInfo: healthInfo,
      description: map['description'] as String? ?? '',
      photos: List<String>.from(map['photos'] ?? []),
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      status: PetStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PetStatus.available,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _toMap(Pet pet) {
    return {
      'ownerId': pet.ownerId,
      'name': pet.name,
      'species': pet.species.name,
      'breed': pet.breed,
      'age': pet.age,
      'gender': pet.gender.name,
      'size': pet.size.name,
      'energyLevel': pet.energyLevel.name,
      'healthInfo': {
        'vaccinated': pet.healthInfo.vaccinated,
        'neutered': pet.healthInfo.neutered,
        'dewormed': pet.healthInfo.dewormed,
        'specialNeeds': pet.healthInfo.specialNeeds,
      },
      'description': pet.description,
      'photos': pet.photos,
      'city': pet.city,
      'state': pet.state,
      'status': pet.status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
