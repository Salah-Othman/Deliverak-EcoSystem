import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository implements IAuthRepository {
  final IAuthService _authService;
  final IFirestoreService _firestoreService;

  AuthRepository({
    required IAuthService authService,
    required IFirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  User? get currentUser => _authService.currentUser;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted onCompleted,
    required PhoneVerificationFailed onFailed,
    required PhoneCodeSent onCodeSent,
    required PhoneCodeAutoRetrievalTimeout onCodeTimeout,
  }) async {
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCompleted: onCompleted,
      onFailed: onFailed,
      onCodeSent: onCodeSent,
      onCodeTimeout: onCodeTimeout,
    );
  }

  @override
  Future<UserModel> signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _authService.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      throw const AuthException(message: 'Failed to sign in');
    }

    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.users,
      documentId: user.uid,
    );

    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }

    final now = DateTime.now();
    final newUser = UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      role: UserRole.customer,
      createdAt: now,
      updatedAt: now,
    );

    await _firestoreService.setDocument(
      collection: FirestorePaths.users,
      documentId: user.uid,
      data: newUser.toMap(),
    );

    return newUser;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;

    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.users,
      documentId: user.uid,
    );

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? email,
    String? profileImage,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (profileImage != null) updates['profileImage'] = profileImage;

    await _firestoreService.updateDocument(
      collection: FirestorePaths.users,
      documentId: uid,
      data: updates,
    );
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
