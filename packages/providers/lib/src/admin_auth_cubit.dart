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

class AdminUnauthenticated extends AdminAuthState {
  const AdminUnauthenticated();
}

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

  void initAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) async {
        if (isClosed) return;
        if (user == null) {
          emit(const AdminUnauthenticated());
          return;
        }
        await _loadUser(user.uid);
      },
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AdminAuthLoading());
    try {
      final user = await _authRepository.signInWithEmail(email, password);
      if (user.role != UserRole.admin) {
        await _authRepository.signOut();
        emit(const AdminAuthError(
          message: 'Access denied. Admin privileges required.',
        ));
        return;
      }
      emit(AdminAuthenticated(user));
    } on AppException catch (e) {
      emit(AdminAuthError(
        message: e.message,
        isRetryable: e.isRetryable,
      ));
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
      if (user == null) {
        emit(const AdminUnauthenticated());
        return;
      }
      if (user.role != UserRole.admin) {
        await _authRepository.signOut();
        emit(const AdminAuthError(
          message: 'Access denied. Admin privileges required.',
        ));
        return;
      }
      emit(AdminAuthenticated(user));
    } catch (e) {
      emit(AdminAuthError(
        message: mapExceptionToMessage(e),
      ));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(const AdminUnauthenticated());
    } catch (e) {
      emit(AdminAuthError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
