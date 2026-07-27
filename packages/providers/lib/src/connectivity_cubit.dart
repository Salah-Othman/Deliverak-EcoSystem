import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object?> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityOnline extends ConnectivityState {
  final ConnectivityResult result;

  const ConnectivityOnline({required this.result});

  @override
  List<Object?> get props => [result];
}

class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(ConnectivityInitial());

  Future<void> init() async {
    final results = await _connectivity.checkConnectivity();
    _emitStatus(results);

    _subscription = _connectivity.onConnectivityChanged.listen(_emitStatus);
  }

  void _emitStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (hasConnection) {
      emit(ConnectivityOnline(
        result: results.firstWhere((r) => r != ConnectivityResult.none),
      ));
    } else {
      emit(const ConnectivityOffline());
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
