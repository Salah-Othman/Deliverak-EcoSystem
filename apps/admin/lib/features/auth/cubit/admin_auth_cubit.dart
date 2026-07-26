import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class AdminAuthState extends Equatable {
  const AdminAuthState();

  @override
  List<Object?> get props => [];
}

class AdminAuthInitial extends AdminAuthState {}

class AdminAuthLoading extends AdminAuthState {}

class AdminAuthenticated extends AdminAuthState {
  final UserModel user;

  const AdminAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AdminUnauthenticated extends AdminAuthState {}

class AdminAuthError extends AdminAuthState {
  final String message;
  final bool isRetryable;

  const AdminAuthError({
    required this.message,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

class AdminAuthCubit extends Cubit<AdminAuthState> {
  final IAuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AdminAuthCubit({required IAuthRepository authRepository})
      : _authRepository = authRepository,
        super(AdminAuthInitial());

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
      } else if (state is! AdminAuthLoading) {
        emit(AdminUnauthenticated());
      }
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AdminAuthLoading());
    try {
      final user = await _authRepository.signInWithEmail(email, password);
      if (user.role != UserRole.admin) {
        await _authRepository.signOut();
        emit(const AdminAuthError(
          message: 'Access denied. Admin account required.',
        ));
        return;
      }
      emit(AdminAuthenticated(user));
    } catch (e) {
      emit(AdminAuthError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> _loadUser(String uid) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null && user.role == UserRole.admin) {
        emit(AdminAuthenticated(user));
      } else {
        await _authRepository.signOut();
        emit(AdminUnauthenticated());
      }
    } catch (e) {
      emit(AdminAuthError(message: mapExceptionToMessage(e)));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(AdminUnauthenticated());
    } catch (e) {
      emit(AdminAuthError(message: mapExceptionToMessage(e)));
    }
  }
}
