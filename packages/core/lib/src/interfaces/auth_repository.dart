import 'package:firebase_auth/firebase_auth.dart';

import 'package:core/src/enums/user_role.dart';
import 'package:core/src/models/user_model.dart';

abstract class IAuthRepository {
  Stream<User?> get authStateChanges;

  User? get currentUser;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted onCompleted,
    required PhoneVerificationFailed onFailed,
    required PhoneCodeSent onCodeSent,
    required PhoneCodeAutoRetrievalTimeout onCodeTimeout,
  });

  Future<UserModel> signInWithCredential(PhoneAuthCredential credential);

  Future<UserModel?> getCurrentUser();

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? email,
    String? profileImage,
  });

  Future<void> completeProfile({
    required String uid,
    required String name,
    required UserRole role,
    String? email,
    String? profileImage,
  });

  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> clearToken();

  Future<void> saveCachedUser(UserModel user);

  Future<UserModel?> getCachedUser();

  Future<void> clearCachedUser();

  Future<UserModel> signInWithEmail(String email, String password);

  Future<UserModel> signUpWithEmail(String email, String password, {required String name});

  Future<void> signOut();
}
