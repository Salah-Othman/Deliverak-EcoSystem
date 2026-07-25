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

class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderError extends OrderState {
  final String message;
  final String? code;
  final bool isRetryable;

  const OrderError({
    required this.message,
    this.code,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, code, isRetryable];
}

class OrderCubit extends Cubit<OrderState> {
  final IOrderRepository _orderRepository;

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
      await _orderRepository.createOrder(
        customerId: customerId,
        vendorId: vendorId,
        items: items,
        totalAmount: totalAmount,
        deliveryFee: deliveryFee,
        deliveryAddress: deliveryAddress,
      );
    } catch (e) {
      emit(OrderError(
        message: mapExceptionToMessage(e),
        code: e is AppException ? e.code : null,
        isRetryable: e is AppException ? e.isRetryable : false,
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
    try {
      final orders = await _orderRepository.getOrders(
        customerId: customerId,
        vendorId: vendorId,
        driverId: driverId,
        status: status,
      );
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  void watchOrders({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
  }) {
    _orderRepository
        .watchOrders(
          customerId: customerId,
          vendorId: vendorId,
          driverId: driverId,
          status: status,
        )
        .listen((orders) {
      emit(OrdersLoaded(orders));
    }).onError((e) {
      emit(OrderError(message: mapExceptionToMessage(e)));
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, status);
    } catch (e) {
      emit(OrderError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }
}
