import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreated extends OrderState {
  final OrderModel order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;
  final bool hasMore;
  final bool isLoadingMore;

  const OrdersLoaded({
    required this.orders,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [orders, hasMore, isLoadingMore];
}

class OrderDetailLoaded extends OrderState {
  final OrderModel order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;
  final bool isRetryable;

  const OrderError({
    required this.message,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

class OrderCubit extends Cubit<OrderState> {
  final IOrderRepository _orderRepository;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  StreamSubscription<OrderModel?>? _orderSubscription;
  DocumentSnapshot? _lastDocument;
  String? _currentCustomerId;
  String? _currentVendorId;
  String? _currentDriverId;
  OrderStatus? _currentStatus;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  OrderCubit({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrderInitial());

  Future<void> createOrder({
    required String customerId,
    required String vendorId,
    required List<OrderItem> items,
    required double totalAmount,
    required double deliveryFee,
    required DeliveryAddress deliveryAddress,
  }) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.createOrder(
        customerId: customerId,
        vendorId: vendorId,
        items: items,
        totalAmount: totalAmount,
        deliveryFee: deliveryFee,
        deliveryAddress: deliveryAddress,
      );
      emit(OrderCreated(order));
    } catch (e) {
      emit(OrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> loadOrders({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
  }) async {
    emit(OrderLoading());
    _currentCustomerId = customerId;
    _currentVendorId = vendorId;
    _currentDriverId = driverId;
    _currentStatus = status;
    _lastDocument = null;
    _hasMore = true;

    try {
      final result = await _orderRepository.getOrdersPaginated(
        customerId: customerId,
        vendorId: vendorId,
        driverId: driverId,
        status: status,
        limit: _pageSize,
      );
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;
      emit(OrdersLoaded(
        orders: result.items,
        hasMore: _hasMore,
      ));
    } catch (e) {
      emit(OrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! OrdersLoaded) return;
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    emit(OrdersLoaded(
      orders: currentState.orders,
      hasMore: _hasMore,
      isLoadingMore: true,
    ));

    try {
      final result = await _orderRepository.getOrdersPaginated(
        customerId: _currentCustomerId,
        vendorId: _currentVendorId,
        driverId: _currentDriverId,
        status: _currentStatus,
        lastDocument: _lastDocument,
        limit: _pageSize,
      );
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;

      emit(OrdersLoaded(
        orders: [...currentState.orders, ...result.items],
        hasMore: _hasMore,
      ));
    } catch (e) {
      emit(OrdersLoaded(
        orders: currentState.orders,
        hasMore: _hasMore,
      ));
    } finally {
      _isLoadingMore = false;
    }
  }

  void watchOrders({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
  }) {
    _ordersSubscription?.cancel();
    _ordersSubscription = _orderRepository
        .watchOrders(
          customerId: customerId,
          vendorId: vendorId,
          driverId: driverId,
          status: status,
        )
        .listen(
      (orders) => emit(OrdersLoaded(orders: orders)),
      onError: (e) => emit(OrderError(message: mapExceptionToMessage(e))),
    );
  }

  void watchOrder(String orderId) {
    _orderSubscription?.cancel();
    _orderSubscription = _orderRepository.watchOrder(orderId).listen(
      (order) {
        if (order != null) {
          emit(OrderDetailLoaded(order));
        }
      },
      onError: (e) => emit(OrderError(message: mapExceptionToMessage(e))),
    );
  }

  void unwatchOrder() {
    _orderSubscription?.cancel();
    _orderSubscription = null;
  }

  Future<void> cancelOrder(String orderId) async {
    emit(OrderLoading());
    try {
      await _orderRepository.updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (e) {
      emit(OrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _orderSubscription?.cancel();
    return super.close();
  }
}
