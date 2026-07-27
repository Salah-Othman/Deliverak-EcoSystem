import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class AdminUserState extends Equatable {
  const AdminUserState();

  @override
  List<Object?> get props => [];
}

class AdminUserInitial extends AdminUserState {}

class AdminUserLoading extends AdminUserState {}

class AdminUsersLoaded extends AdminUserState {
  final List<UserModel> users;
  final UserRole? filter;

  const AdminUsersLoaded({required this.users, this.filter});

  @override
  List<Object?> get props => [users, filter];
}

class AdminUserError extends AdminUserState {
  final String message;
  final String? code;
  final bool isRetryable;

  const AdminUserError({
    required this.message,
    this.code,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, code, isRetryable];
}

class AdminUserCubit extends Cubit<AdminUserState> {
  final IUserRepository _userRepository;
  StreamSubscription<List<UserModel>>? _usersSubscription;

  AdminUserCubit({required IUserRepository userRepository})
      : _userRepository = userRepository,
        super(AdminUserInitial());

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }

  Future<void> loadUsers({UserRole? role}) async {
    emit(AdminUserLoading());
    try {
      final users = await retryWithBackoff(() => _userRepository.getUsers(role: role));
      emit(AdminUsersLoaded(users: users, filter: role));
    } catch (e) {
      emit(AdminUserError(
        message: mapExceptionToMessage(e),
        code: e is AppException ? e.code : null,
        isRetryable: isRetryableError(e),
      ));
    }
  }

  void watchUsers({UserRole? role}) {
    _usersSubscription?.cancel();
    _usersSubscription = _userRepository.watchUsers(role: role).listen(
      (users) => emit(AdminUsersLoaded(users: users, filter: role)),
      onError: (e) => emit(AdminUserError(
        message: mapExceptionToMessage(e),
        code: e is AppException ? e.code : null,
        isRetryable: isRetryableError(e),
      )),
    );
  }
}
