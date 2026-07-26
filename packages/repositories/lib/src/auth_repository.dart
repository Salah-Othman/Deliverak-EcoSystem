import 'dart:convert';

import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _kTokenKey = 'auth_token';
const _kUserKey = 'cached_user';
const _kUserBox = 'user_box';

class AuthRepository implements IAuthRepository {
  final IAuthService _authService;
  final IFirestoreService _firestoreService;
  final ISecureStorageService _secureStorage;
  final ICacheService _cacheService;

  AuthRepository({
    required IAuthService authService,
    required IFirestoreService firestoreService,
    required ISecureStorageService secureStorage,
    required ICacheService cacheService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _secureStorage = secureStorage,
        _cacheService = cacheService;

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

    final token = await user.getIdToken();
    if (token != null) {
      await saveToken(token);
    }

    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.users,
      documentId: user.uid,
    );

    if (doc.exists) {
      final userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      await saveCachedUser(userModel);
      return userModel;
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

    await saveCachedUser(newUser);
    return newUser;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;

    final cached = await getCachedUser();
    if (cached != null && cached.uid == user.uid) {
      return cached;
    }

    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.users,
      documentId: user.uid,
    );

    if (!doc.exists) return null;

    final userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
    await saveCachedUser(userModel);
    return userModel;
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

    final current = await getCachedUser();
    if (current != null) {
      await saveCachedUser(current.copyWith(
        name: name,
        email: email,
        profileImage: profileImage,
      ));
    }
  }

  @override
  Future<void> completeProfile({
    required String uid,
    required String name,
    required UserRole role,
    String? email,
    String? profileImage,
  }) async {
    final existing = await getCachedUser();

    final updates = <String, dynamic>{
      'name': name,
      'role': role.name,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (email != null) updates['email'] = email;
    if (profileImage != null) updates['profileImage'] = profileImage;

    await _firestoreService.updateDocument(
      collection: FirestorePaths.users,
      documentId: uid,
      data: updates,
    );

    if (existing != null) {
      final updatedUser = existing.copyWith(
        name: name,
        role: role,
        email: email,
        profileImage: profileImage,
      );
      await saveCachedUser(updatedUser);
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _kTokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _kTokenKey);
  }

  @override
  Future<void> clearToken() async {
    await _secureStorage.delete(key: _kTokenKey);
  }

  @override
  Future<void> saveCachedUser(UserModel user) async {
    await _cacheService.put<String>(
      _kUserBox,
      _kUserKey,
      jsonEncode(user.toMap()),
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final json = _cacheService.get<String>(_kUserBox, _kUserKey);
    if (json == null) return null;
    return UserModel.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> clearCachedUser() async {
    await _cacheService.delete(_kUserBox, _kUserKey);
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
    await clearToken();
    await clearCachedUser();
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final userCredential = await _authService.signInWithEmail(email, password);
    final user = userCredential.user;

    if (user == null) {
      throw const AuthException(message: 'Failed to sign in');
    }

    final token = await user.getIdToken();
    if (token != null) {
      await saveToken(token);
    }

    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.users,
      documentId: user.uid,
    );

    if (doc.exists) {
      final userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      await saveCachedUser(userModel);
      return userModel;
    }

    throw const AuthException(message: 'User not found');
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password, {required String name, required UserRole role}) async {
    final userCredential = await _authService.signUpWithEmail(email, password);
    final user = userCredential.user;

    if (user == null) {
      throw const AuthException(message: 'Failed to create account');
    }

    final token = await user.getIdToken();
    if (token != null) {
      await saveToken(token);
    }

    final now = DateTime.now();
    final newUser = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      phone: '',
      role: role,
      createdAt: now,
      updatedAt: now,
    );

    await _firestoreService.setDocument(
      collection: FirestorePaths.users,
      documentId: user.uid,
      data: newUser.toMap(),
    );

    await saveCachedUser(newUser);
    return newUser;
  }
}
