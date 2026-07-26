import 'package:equatable/equatable.dart';

import '../enums/order_status.dart';
import '../exceptions/app_exception.dart';

class OrderItem extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [productId, name, quantity, price];
}

class DeliveryAddress extends Equatable {
  final double lat;
  final double lng;
  final String address;
  final String name;
  final String phone;

  const DeliveryAddress({
    required this.lat,
    required this.lng,
    required this.address,
    required this.name,
    required this.phone,
  });

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
      'name': name,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [lat, lng, address, name, phone];
}

class OrderModel extends Equatable {
  final String orderId;
  final String customerId;
  final String vendorId;
  final String? driverId;
  final List<OrderItem> items;
  final double totalAmount;
  final double deliveryFee;
  final OrderStatus status;
  final DeliveryAddress deliveryAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.orderId,
    required this.customerId,
    required this.vendorId,
    this.driverId,
    required this.items,
    required this.totalAmount,
    required this.deliveryFee,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      driverId: map['driverId'] as String?,
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: DeliveryAddress.fromMap(map['deliveryAddress'] as Map<String, dynamic>? ?? {}),
      paymentMethod: map['paymentMethod'] as String? ?? 'cash',
      createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'vendorId': vendorId,
      'driverId': driverId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'status': status.name,
      'deliveryAddress': deliveryAddress.toMap(),
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? driverId,
    OrderStatus? status,
    List<OrderItem>? items,
    double? totalAmount,
    double? deliveryFee,
  }) {
    return OrderModel(
      orderId: orderId,
      customerId: customerId,
      vendorId: vendorId,
      driverId: driverId ?? this.driverId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [orderId, customerId, vendorId, driverId, items, totalAmount, deliveryFee, status, deliveryAddress, paymentMethod, createdAt, updatedAt];

  void validate() {
    if (orderId.trim().isEmpty) {
      throw const ValidationException(message: 'Order ID is required');
    }
    if (customerId.trim().isEmpty) {
      throw const ValidationException(message: 'Customer ID is required');
    }
    if (vendorId.trim().isEmpty) {
      throw const ValidationException(message: 'Vendor ID is required');
    }
    if (items.isEmpty) {
      throw const ValidationException(message: 'Order must contain at least one item');
    }
    for (final item in items) {
      if (item.quantity < 1 || item.quantity > 99) {
        throw const ValidationException(message: 'Item quantity must be between 1 and 99');
      }
      if (item.price < 0) {
        throw const ValidationException(message: 'Item price cannot be negative');
      }
    }
    final itemsTotal = items.fold<double>(0, (sum, item) => sum + item.price * item.quantity);
    final expectedTotal = itemsTotal + deliveryFee;
    if ((totalAmount - expectedTotal).abs() > 0.01) {
      throw const ValidationException(message: 'Order total does not match items total plus delivery fee');
    }
    if (totalAmount < 0) {
      throw const ValidationException(message: 'Total amount cannot be negative');
    }
    if (deliveryFee < 0) {
      throw const ValidationException(message: 'Delivery fee cannot be negative');
    }
    if (deliveryAddress.address.trim().isEmpty) {
      throw const ValidationException(message: 'Delivery address is required');
    }
    if (deliveryAddress.name.trim().isEmpty) {
      throw const ValidationException(message: 'Recipient name is required');
    }
    if (deliveryAddress.phone.trim().isEmpty) {
      throw const ValidationException(message: 'Recipient phone is required');
    }
  }
}
