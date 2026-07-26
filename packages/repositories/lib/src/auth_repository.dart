import 'dart:async';
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
  final INotificationService? _notificationService;

  StreamSubscription<String>? _fcmTokenSubscription;

  AuthRepository({
    required IAuthService authService,
    required IFirestoreService firestoreService,
    required ISecureStorageService secureStorage,
    required ICacheService cacheService,
    INotificationService? notificationService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _secureStorage = secureStorage,
        _cacheService = cacheService,
        _notificationService = notificationService;

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
    startFcmTokenListener(newUser.uid);
    return newUser;
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final userCredential =
        await _authService.signInWithEmailAndPassword(email, password);
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
      startFcmTokenListener(userModel.uid);
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
    startFcmTokenListener(newUser.uid);
    return newUser;
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password,
      {String? name}) async {
    final userCredential =
        await _authService.createUserWithEmailAndPassword(email, password);
    final user = userCredential.user;

    if (user == null) {
      throw const AuthException(message: 'Failed to create account');
    }

    if (name != null) {
      await user.updateDisplayName(name);
    }

    final token = await user.getIdToken();
    if (token != null) {
      await saveToken(token);
    }

    final now = DateTime.now();
    final newUser = UserModel(
      uid: user.uid,
      name: name ?? '',
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
    startFcmTokenListener(newUser.uid);
    return newUser;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;

    startFcmTokenListener(user.uid);

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
    if (name != null && (name.trim().isEmpty || name.trim().length > 50)) {
      throw const ValidationException(message: 'Name must be 1–50 characters');
    }
    if (email != null && email.trim().isNotEmpty &&
        !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      throw const ValidationException(message: 'Enter a valid email address');
    }

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
    if (name.trim().isEmpty || name.trim().length > 50) {
      throw const ValidationException(message: 'Name must be 1–50 characters');
    }
    if (email != null && email.trim().isNotEmpty &&
        !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      throw const ValidationException(message: 'Enter a valid email address');
    }

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
    await _clearFcmToken();
    _fcmTokenSubscription?.cancel();
    await _authService.signOut();
    await clearToken();
    await clearCachedUser();
  }

  void startFcmTokenListener(String uid) {
    _fcmTokenSubscription?.cancel();
    _saveFcmToken(uid);
    _fcmTokenSubscription = _notificationService?.onTokenRefresh.listen(
      (token) => _updateFcmToken(uid, token),
    );
  }

  Future<void> _saveFcmToken(String uid) async {
    final service = _notificationService;
    if (service == null) return;
    try {
      final token = await service.getToken();
      if (token != null) {
        await _updateFcmToken(uid, token);
      }
    } catch (_) {}
  }

  Future<void> _updateFcmToken(String uid, String token) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestorePaths.users,
        documentId: uid,
        data: {'fcmToken': token},
      );
    } catch (_) {}
  }

  Future<void> _clearFcmToken() async {
    final user = _authService.currentUser;
    if (user == null) return;
    try {
      await _firestoreService.updateDocument(
        collection: FirestorePaths.users,
        documentId: user.uid,
        data: {'fcmToken': null},
      );
    } catch (_) {}
  }
}
