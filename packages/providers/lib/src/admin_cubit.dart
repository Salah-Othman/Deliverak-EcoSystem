import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final int totalUsers;
  final int totalVendors;
  final int totalOrders;
  final int totalDrivers;
  final double totalRevenue;
  final List<OrderModel> recentOrders;
  final Map<OrderStatus, int> ordersByStatus;

  const AdminDashboardLoaded({
    required this.totalUsers,
    required this.totalVendors,
    required this.totalOrders,
    required this.totalDrivers,
    required this.totalRevenue,
    required this.recentOrders,
    required this.ordersByStatus,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        totalVendors,
        totalOrders,
        totalDrivers,
        totalRevenue,
        recentOrders,
        ordersByStatus,
      ];
}

class AdminError extends AdminState {
  final String message;
  final bool isRetryable;

  const AdminError({
    required this.message,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

class AdminCubit extends Cubit<AdminState> {
  final IUserRepository _userRepository;
  final IVendorRepository _vendorRepository;
  final IOrderRepository _orderRepository;
  final IDriverRepository _driverRepository;

  AdminCubit({
    required IUserRepository userRepository,
    required IVendorRepository vendorRepository,
    required IOrderRepository orderRepository,
    required IDriverRepository driverRepository,
  })  : _userRepository = userRepository,
        _vendorRepository = vendorRepository,
        _orderRepository = orderRepository,
        _driverRepository = driverRepository,
        super(AdminInitial());

  Future<void> loadDashboard() async {
    emit(AdminLoading());
    try {
      final results = await retryWithBackoff(() => Future.wait([
        _userRepository.getUsersCount(),
        _vendorRepository.getVendors(),
        _orderRepository.getOrders(),
        _driverRepository.getAvailableDrivers(),
      ]));

      final totalUsers = results[0] as int;
      final vendors = results[1] as List<VendorModel>;
      final orders = results[2] as List<OrderModel>;
      final drivers = results[3] as List<DriverModel>;

      final totalRevenue = orders.fold<double>(
        0,
        (sum, order) => sum + order.totalAmount,
      );

      final recentOrders = orders.length > 10 ? orders.sublist(0, 10) : orders;

      final ordersByStatus = <OrderStatus, int>{};
      for (final status in OrderStatus.values) {
        ordersByStatus[status] = orders
            .where((o) => o.status == status)
            .length;
      }

      emit(AdminDashboardLoaded(
        totalUsers: totalUsers,
        totalVendors: vendors.length,
        totalOrders: orders.length,
        totalDrivers: drivers.length,
        totalRevenue: totalRevenue,
        recentOrders: recentOrders,
        ordersByStatus: ordersByStatus,
      ));
    } catch (e) {
      emit(AdminError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }
}
