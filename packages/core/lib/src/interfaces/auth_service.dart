import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  User? get currentUser;

  Stream<User?> get authStateChanges;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted onCompleted,
    required PhoneVerificationFailed onFailed,
    required PhoneCodeSent onCodeSent,
    required PhoneCodeAutoRetrievalTimeout onCodeTimeout,
  });

  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential);

  Future<void> signOut();

  String? getPhoneNumber();
}
