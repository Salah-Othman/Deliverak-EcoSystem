import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

// ── States ──────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class PhoneSubmitted extends AuthState {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  const PhoneSubmitted({
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  @override
  List<Object?> get props => [verificationId, phoneNumber, resendToken];
}

class ProfileSetup extends AuthState {
  final UserModel user;
  final UserRole? selectedRole;

  const ProfileSetup({
    required this.user,
    this.selectedRole,
  });

  @override
  List<Object?> get props => [user, selectedRole];
}

class AuthError extends AuthState {
  final String message;
  final String? code;
  final bool isRetryable;
  final AuthState? previousState;

  const AuthError({
    required this.message,
    this.code,
    this.isRetryable = false,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, code, isRetryable, previousState];
}

// ── Cubit ───────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit({required IAuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial());

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  void initAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _loadUser(user.uid);
      } else if (state is! PhoneSubmitted && state is! ProfileSetup) {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    emit(AuthLoading());
    try {
      await _authRepository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCompleted: _onVerificationCompleted,
        onFailed: _onVerificationFailed,
        onCodeSent: (verificationId, resendToken) {
          emit(PhoneSubmitted(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
            resendToken: resendToken,
          ));
        },
        onCodeTimeout: (verificationId) {
          emit(const AuthError(
            message: 'Verification code timed out. Please try again.',
            isRetryable: true,
          ));
        },
      );
    } catch (e) {
      emit(AuthError(
        message: mapExceptionToMessage(e),
        code: e is AppException ? e.code : null,
        isRetryable: e is AppException ? e.isRetryable : false,
      ));
    }
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) {
    _submitCredential(credential);
  }

  void _onVerificationFailed(FirebaseAuthException error) {
    emit(AuthError(
      message: _mapAuthError(error),
      code: error.code,
      isRetryable: _isRetryableAuthError(error),
      previousState: state,
    ));
  }

  Future<void> submitOtp(String otp) async {
    final currentState = state;
    if (currentState is! PhoneSubmitted) {
      emit(const AuthError(
        message: 'Verification session expired. Please try again.',
        isRetryable: true,
      ));
      return;
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: currentState.verificationId,
      smsCode: otp,
    );

    await _submitCredential(credential);
  }

  Future<void> resendOtp() async {
    final currentState = state;
    if (currentState is! PhoneSubmitted) return;

    await verifyPhoneNumber(currentState.phoneNumber);
  }

  Future<void> _submitCredential(PhoneAuthCredential credential) async {
    final previousState = state;
    emit(AuthLoading());
    try {
      await _authRepository.signInWithCredential(credential);
    } catch (e) {
      emit(AuthError(
        message: mapExceptionToMessage(e),
        code: e is AppException ? e.code : null,
        isRetryable: e is AppException ? e.isRetryable : false,
        previousState: previousState,
      ));
    }
  }

  Future<void> _loadUser(String uid) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        if (user.name.isEmpty) {
          emit(ProfileSetup(user: user));
        } else {
          emit(Authenticated(user));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: mapExceptionToMessage(e)));
    }
  }

  void selectRole(UserRole role) {
    final currentState = state;
    if (currentState is ProfileSetup) {
      emit(ProfileSetup(user: currentState.user, selectedRole: role));
    }
  }

  Future<void> completeProfile({
    required String name,
    required UserRole role,
    String? email,
    String? profileImage,
  }) async {
    final currentState = state;
    if (currentState is! ProfileSetup) return;

    emit(AuthLoading());
    try {
      await _authRepository.completeProfile(
        uid: currentState.user.uid,
        name: name,
        role: role,
        email: email,
        profileImage: profileImage,
      );

      final updatedUser = currentState.user.copyWith(
        name: name,
        role: role,
        email: email,
        profileImage: profileImage,
      );

      emit(Authenticated(updatedUser));
    } catch (e) {
      emit(AuthError(
        message: mapExceptionToMessage(e),
        code: e is AppException ? e.code : null,
        isRetryable: e is AppException ? e.isRetryable : false,
      ));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? profileImage,
  }) async {
    final currentState = state;
    if (currentState is! Authenticated) return;

    try {
      await _authRepository.updateUserProfile(
        uid: currentState.user.uid,
        name: name,
        email: email,
        profileImage: profileImage,
      );
      await _loadUser(currentState.user.uid);
    } catch (e) {
      emit(AuthError(message: mapExceptionToMessage(e)));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    final previousState = state;
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(
        message: _mapAuthError(e),
        code: e.code,
        isRetryable: _isRetryableAuthError(e),
        previousState: previousState,
      ));
    } catch (e) {
      emit(AuthError(
        message: mapExceptionToMessage(e),
        code: e is AppException ? e.code : null,
        isRetryable: e is AppException ? e.isRetryable : false,
        previousState: previousState,
      ));
    }
  }

  Future<void> signUpWithEmail(String email, String password,
      {String? name}) async {
    final previousState = state;
    emit(AuthLoading());
    try {
      await _authRepository.signUpWithEmail(email, password, name: name);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(
        message: _mapAuthError(e),
        code: e.code,
        isRetryable: _isRetryableAuthError(e),
        previousState: previousState,
      ));
    } catch (e) {
      emit(AuthError(
        message: mapExceptionToMessage(e),
        code: e is AppException ? e.code : null,
        isRetryable: e is AppException ? e.isRetryable : false,
        previousState: previousState,
      ));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: mapExceptionToMessage(e)));
    }
  }

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid.';
      case 'invalid-verification-code':
        return 'The OTP code is invalid. Please try again.';
      case 'invalid-verification-id':
        return 'Verification session expired. Please request a new code.';
      case 'session-expired':
        return 'Verification session expired. Please request a new code.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }

  bool _isRetryableAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'network-request-failed':
      case 'too-many-requests':
        return true;
      default:
        return false;
    }
  }
}
