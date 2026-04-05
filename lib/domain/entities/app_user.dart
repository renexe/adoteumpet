/// Representa um usuário autenticado no aplicativo.
///
/// Não há distinção entre doador e adotante: qualquer usuário pode
/// cadastrar animais para doação e também se candidatar a adotar.
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? profilePicture;
  final String? bio;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profilePicture,
    this.bio,
    required this.createdAt,
  });

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? profilePicture,
    String? bio,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Tipos de moradia do usuário — usados para filtrar animais compatíveis.
enum HousingType {
  smallApartment('Apartamento pequeno'),
  largeApartment('Apartamento grande'),
  houseNoYard('Casa sem quintal'),
  houseWithYard('Casa com quintal');

  final String label;
  const HousingType(this.label);
}

/// Tempo disponível por dia para cuidar de um animal.
enum AvailableTime {
  lessThan2h('Menos de 2 horas'),
  between2and4h('2 a 4 horas'),
  between4and6h('4 a 6 horas'),
  moreThan6h('Mais de 6 horas');

  final String label;
  const AvailableTime(this.label);
}
