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

  /// Localização do usuário (cidade e estado).
  final UserLocation? location;

  /// Informações de contato do usuário.
  final UserContact? contact;

  /// Configurações de privacidade do perfil.
  final UserPrivacy privacy;

  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profilePicture,
    this.bio,
    this.location,
    this.contact,
    this.privacy = const UserPrivacy(),
    required this.createdAt,
  });

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? profilePicture,
    String? bio,
    UserLocation? location,
    UserContact? contact,
    UserPrivacy? privacy,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      contact: contact ?? this.contact,
      privacy: privacy ?? this.privacy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Localização do usuário.
class UserLocation {
  final String city;
  final String state;

  const UserLocation({
    required this.city,
    required this.state,
  });

  String get displayName => '$city, $state';

  UserLocation copyWith({String? city, String? state}) {
    return UserLocation(
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }
}

/// Informações de contato do usuário.
class UserContact {
  final String? phone;
  final String? whatsapp;
  final String? instagram;

  const UserContact({
    this.phone,
    this.whatsapp,
    this.instagram,
  });

  UserContact copyWith({
    String? phone,
    String? whatsapp,
    String? instagram,
  }) {
    return UserContact(
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      instagram: instagram ?? this.instagram,
    );
  }
}

/// Configurações de privacidade do perfil.
///
/// Por padrão, endereço e contatos são privados.
class UserPrivacy {
  /// Se verdadeiro, a cidade/estado do usuário é exibida publicamente.
  final bool showLocation;

  /// Se verdadeiro, os dados de contato (telefone, WhatsApp, Instagram)
  /// são exibidos publicamente no perfil e nas páginas de pets.
  final bool showContact;

  const UserPrivacy({
    this.showLocation = false,
    this.showContact = false,
  });

  UserPrivacy copyWith({bool? showLocation, bool? showContact}) {
    return UserPrivacy(
      showLocation: showLocation ?? this.showLocation,
      showContact: showContact ?? this.showContact,
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
