/// Representa um usuário autenticado no aplicativo.
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? profilePicture;
  final UserType userType;
  final QuizAnswers? quizAnswers;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profilePicture,
    required this.userType,
    this.quizAnswers,
    required this.createdAt,
  });

  bool get isAdopter => userType == UserType.adopter;
  bool get isDonor => userType == UserType.donor;
  bool get hasCompletedQuiz => quizAnswers != null;

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? profilePicture,
    UserType? userType,
    QuizAnswers? quizAnswers,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profilePicture: profilePicture ?? this.profilePicture,
      userType: userType ?? this.userType,
      quizAnswers: quizAnswers ?? this.quizAnswers,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Respostas do quiz de estilo de vida do adotante.
class QuizAnswers {
  final HousingType housing;
  final AvailableTime availableTime;
  final bool hasChildren;
  final bool hasOtherPets;
  final List<String> traits;

  const QuizAnswers({
    required this.housing,
    required this.availableTime,
    required this.hasChildren,
    required this.hasOtherPets,
    this.traits = const [],
  });
}

enum UserType {
  adopter('Adotante'),
  donor('Doador');

  final String label;
  const UserType(this.label);
}

enum HousingType {
  smallApartment('Apartamento pequeno'),
  largeApartment('Apartamento grande'),
  houseNoYard('Casa sem quintal'),
  houseWithYard('Casa com quintal');

  final String label;
  const HousingType(this.label);
}

enum AvailableTime {
  lessThan2h('Menos de 2 horas'),
  between2and4h('2 a 4 horas'),
  between4and6h('4 a 6 horas'),
  moreThan6h('Mais de 6 horas');

  final String label;
  const AvailableTime(this.label);
}
