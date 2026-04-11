import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';

/// Repositório de usuários — lê e escreve perfis no Firestore.
///
/// Coleção: `users/{uid}`
class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('users');

  // ── Leitura ────────────────────────────────────────────────────────────────

  /// Retorna o perfil do usuário ou null se ainda não existir.
  Future<AppUser?> fetchUser(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return _fromMap(uid, doc.data()!);
    } catch (e) {
      throw DatabaseException('Erro ao buscar perfil: $e');
    }
  }

  /// Stream em tempo real do perfil do usuário.
  Stream<AppUser?> watchUser(String uid) {
    return _col.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return _fromMap(uid, doc.data()!);
    });
  }

  // ── Escrita ────────────────────────────────────────────────────────────────

  /// Cria ou atualiza o perfil do usuário no Firestore.
  Future<void> saveUser(AppUser user) async {
    try {
      await _col.doc(user.uid).set(_toMap(user), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Erro ao salvar perfil: $e');
    }
  }

  /// Atualiza campos específicos do perfil.
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    try {
      await _col.doc(uid).update(fields);
    } catch (e) {
      throw DatabaseException('Erro ao atualizar perfil: $e');
    }
  }

  // ── Serialização ───────────────────────────────────────────────────────────

  AppUser _fromMap(String uid, Map<String, dynamic> map) {
    UserLocation? location;
    if (map['location'] != null) {
      final loc = map['location'] as Map<String, dynamic>;
      location = UserLocation(
        city: loc['city'] as String? ?? '',
        state: loc['state'] as String? ?? '',
      );
    }

    UserContact? contact;
    if (map['contact'] != null) {
      final c = map['contact'] as Map<String, dynamic>;
      contact = UserContact(
        phone: c['phone'] as String?,
        whatsapp: c['whatsapp'] as String?,
        instagram: c['instagram'] as String?,
      );
    }

    final privMap = map['privacy'] as Map<String, dynamic>?;
    final privacy = UserPrivacy(
      showLocation: privMap?['showLocation'] as bool? ?? false,
      showContact: privMap?['showContact'] as bool? ?? false,
    );

    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      profilePicture: map['profilePicture'] as String?,
      bio: map['bio'] as String?,
      location: location,
      contact: contact,
      privacy: privacy,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _toMap(AppUser user) {
    return {
      'email': user.email,
      'displayName': user.displayName,
      if (user.profilePicture != null)
        'profilePicture': user.profilePicture,
      if (user.bio != null) 'bio': user.bio,
      if (user.location != null)
        'location': {
          'city': user.location!.city,
          'state': user.location!.state,
        },
      if (user.contact != null)
        'contact': {
          if (user.contact!.phone != null) 'phone': user.contact!.phone,
          if (user.contact!.whatsapp != null)
            'whatsapp': user.contact!.whatsapp,
          if (user.contact!.instagram != null)
            'instagram': user.contact!.instagram,
        },
      'privacy': {
        'showLocation': user.privacy.showLocation,
        'showContact': user.privacy.showContact,
      },
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
