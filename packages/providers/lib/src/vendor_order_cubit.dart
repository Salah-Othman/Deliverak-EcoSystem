import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class VendorOrderState extends Equatable {
  const VendorOrderState();

  @override
  List<Object?> get props => [];
}

class VendorOrderInitial extends VendorOrderState {}

class VendorOrderLoading extends VendorOrderState {}

class VendorOrdersLoaded extends VendorOrderState {
  final List<OrderModel> pendingOrders;
  final List<OrderModel> activeOrders;
  final List<OrderModel> completedOrders;

  const VendorOrdersLoaded({
    required this.pendingOrders,
    required this.activeOrders,
    required this.completedOrders,
  });

  @override
  List<Object?> get props => [pendingOrders, activeOrders, completedOrders];
}

class VendorOrderDetailLoaded extends VendorOrderState {
  final OrderModel order;

  const VendorOrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class VendorOrderError extends VendorOrderState {
  final String message;
  final bool isRetryable;

  const VendorOrderError({
    required this.message,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

class VendorOrderActionSuccess extends VendorOrderState {
  final String message;

  const VendorOrderActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VendorOrderCubit extends Cubit<VendorOrderState> {
  final IOrderRepository _orderRepository;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  StreamSubscription<OrderModel?>? _orderSubscription;

  VendorOrderCubit({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(VendorOrderInitial());

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _orderSubscription?.cancel();
    return super.close();
  }

  void watchAllOrders(String vendorId) {
    _ordersSubscription?.cancel();
    _ordersSubscription = _orderRepository
        .watchOrders(vendorId: vendorId)
        .listen(
      (orders) {
        final pending = orders
            .where((o) => o.status == OrderStatus.pending)
            .toList();
        final active = orders
            .where((o) =>
                o.status == OrderStatus.accepted ||
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.pickedUp ||
                o.status == OrderStatus.inTransit)
            .toList();
        final completed = orders
            .where((o) =>
                o.status == OrderStatus.delivered ||
                o.status == OrderStatus.cancelled)
            .toList();
        emit(VendorOrdersLoaded(
          pendingOrders: pending,
          activeOrders: active,
          completedOrders: completed,
        ));
      },
      onError: (e) =>
          emit(VendorOrderError(message: mapExceptionToMessage(e))),
    );
  }

  void watchOrder(String orderId) {
    _orderSubscription?.cancel();
    _orderSubscription = _orderRepository.watchOrder(orderId).listen(
      (order) {
        if (order != null) {
          emit(VendorOrderDetailLoaded(order));
        }
      },
      onError: (e) =>
          emit(VendorOrderError(message: mapExceptionToMessage(e))),
    );
  }

  void unwatchOrder() {
    _orderSubscription?.cancel();
    _orderSubscription = null;
  }

  Future<void> acceptOrder(String orderId) async {
    emit(VendorOrderLoading());
    try {
      await _orderRepository.updateOrderStatus(orderId, OrderStatus.accepted);
      emit(const VendorOrderActionSuccess('Order accepted!'));
    } catch (e) {
      emit(VendorOrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> rejectOrder(String orderId) async {
    emit(VendorOrderLoading());
    try {
      await _orderRepository.updateOrderStatus(orderId, OrderStatus.cancelled);
      emit(const VendorOrderActionSuccess('Order rejected.'));
    } catch (e) {
      emit(VendorOrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> markPreparing(String orderId) async {
    emit(VendorOrderLoading());
    try {
      await _orderRepository.updateOrderStatus(orderId, OrderStatus.preparing);
      emit(const VendorOrderActionSuccess('Order is now being prepared.'));
    } catch (e) {
      emit(VendorOrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> markReady(String orderId) async {
    emit(VendorOrderLoading());
    try {
      await _orderRepository.updateOrderStatus(orderId, OrderStatus.pickedUp);
      emit(const VendorOrderActionSuccess('Order is ready for pickup!'));
    } catch (e) {
      emit(VendorOrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }
}
