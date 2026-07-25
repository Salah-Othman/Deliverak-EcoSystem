import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> signOut();
}
