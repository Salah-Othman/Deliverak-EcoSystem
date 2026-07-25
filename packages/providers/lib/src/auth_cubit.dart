import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

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

class AuthError extends AuthState {
  final String message;
  final String? code;
  final bool isRetryable;

  const AuthError({
    required this.message,
    this.code,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, code, isRetryable];
}

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _authRepository;

  AuthCubit({required IAuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(
        message: mapExceptionToMessage(e),
        code: e is AppException ? e.code : null,
        isRetryable: e is AppException ? e.isRetryable : false,
      ));
    }
  }

  void initAuthListener() {
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _loadUser(user.uid);
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> _loadUser(String uid) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: mapExceptionToMessage(e)));
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

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: mapExceptionToMessage(e)));
    }
  }
}
