import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class DriverOrderState extends Equatable {
  const DriverOrderState();

  @override
  List<Object?> get props => [];
}

class DriverOrderInitial extends DriverOrderState {}

class DriverOrderLoading extends DriverOrderState {}

class AvailableOrdersLoaded extends DriverOrderState {
  final List<OrderModel> orders;

  const AvailableOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class ActiveOrderLoaded extends DriverOrderState {
  final OrderModel order;

  const ActiveOrderLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class DriverOrdersLoaded extends DriverOrderState {
  final List<OrderModel> orders;
  final double totalEarnings;

  const DriverOrdersLoaded({
    required this.orders,
    this.totalEarnings = 0,
  });

  @override
  List<Object?> get props => [orders, totalEarnings];
}

class DriverOrderError extends DriverOrderState {
  final String message;
  final bool isRetryable;

  const DriverOrderError({
    required this.message,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

class DriverOrderActionSuccess extends DriverOrderState {
  final String message;

  const DriverOrderActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DriverOrderCubit extends Cubit<DriverOrderState> {
  final IOrderRepository _orderRepository;
  final IDriverRepository _driverRepository;
  StreamSubscription<List<OrderModel>>? _availableOrdersSubscription;
  StreamSubscription<List<OrderModel>>? _activeOrderSubscription;

  DriverOrderCubit({
    required IOrderRepository orderRepository,
    required IDriverRepository driverRepository,
  })  : _orderRepository = orderRepository,
        _driverRepository = driverRepository,
        super(DriverOrderInitial());

  @override
  Future<void> close() {
    _availableOrdersSubscription?.cancel();
    _activeOrderSubscription?.cancel();
    return super.close();
  }

  void watchAvailableOrders() {
    _availableOrdersSubscription?.cancel();
    _availableOrdersSubscription = _orderRepository
        .watchOrders(status: OrderStatus.accepted)
        .map((orders) => orders.where((o) => o.driverId == null).toList())
        .listen(
      (orders) => emit(AvailableOrdersLoaded(orders)),
      onError: (e) =>
          emit(DriverOrderError(message: mapExceptionToMessage(e))),
    );
  }

  void watchActiveOrder(String driverId) {
    _activeOrderSubscription?.cancel();
    _activeOrderSubscription = _orderRepository
        .watchOrders(driverId: driverId)
        .map((orders) => orders.where((o) => o.status.isActive).toList())
        .listen(
      (orders) {
        if (orders.isNotEmpty) {
          emit(ActiveOrderLoaded(orders.first));
        }
      },
      onError: (e) =>
          emit(DriverOrderError(message: mapExceptionToMessage(e))),
    );
  }

  Future<void> acceptOrder(String orderId, String driverId) async {
    emit(DriverOrderLoading());
    try {
      await _orderRepository.assignDriver(orderId, driverId);
      await _orderRepository.updateOrderStatus(orderId, OrderStatus.pickedUp);
      emit(const DriverOrderActionSuccess('Order accepted!'));
    } catch (e) {
      emit(DriverOrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> startDelivery(String orderId) async {
    emit(DriverOrderLoading());
    try {
      await _orderRepository.updateOrderStatus(orderId, OrderStatus.inTransit);
      emit(const DriverOrderActionSuccess('Delivery started!'));
    } catch (e) {
      emit(DriverOrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> completeDelivery(String orderId, String driverId) async {
    emit(DriverOrderLoading());
    try {
      await _orderRepository.updateOrderStatus(orderId, OrderStatus.delivered);

      final driver = await _driverRepository.getDriver(driverId);
      if (driver != null) {
        await _driverRepository.updateOnlineStatus(driver.driverId, true);
      }

      emit(const DriverOrderActionSuccess('Delivery completed!'));
    } catch (e) {
      emit(DriverOrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> loadDeliveryHistory(String driverId) async {
    emit(DriverOrderLoading());
    try {
      final orders = await _orderRepository.getOrders(driverId: driverId);
      final deliveredOrders =
          orders.where((o) => o.status == OrderStatus.delivered).toList();
      final totalEarnings =
          deliveredOrders.fold<double>(0, (sum, o) => sum + o.deliveryFee);

      emit(DriverOrdersLoaded(
        orders: deliveredOrders,
        totalEarnings: totalEarnings,
      ));
    } catch (e) {
      emit(DriverOrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }
}
