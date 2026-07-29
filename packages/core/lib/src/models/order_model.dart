import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/order_status.dart';
import '../exceptions/app_exception.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

DateTime _dateTimefromJson(String value) => DateTime.parse(value);

String _dateTimetoJson(DateTime value) => value.toIso8601String();

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String productId,
    required String name,
    required int quantity,
    required double price,
  }) = _OrderItem;

  const OrderItem._();

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  factory OrderItem.fromMap(Map<String, dynamic> map) =>
      OrderItem.fromJson(map);

  Map<String, dynamic> toMap() => toJson();

  double get total => quantity * price;
}

@freezed
abstract class DeliveryAddress with _$DeliveryAddress {
  const factory DeliveryAddress({
    required double lat,
    required double lng,
    required String address,
    required String name,
    required String phone,
  }) = _DeliveryAddress;

  const DeliveryAddress._();

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      _$DeliveryAddressFromJson(json);

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) =>
      DeliveryAddress.fromJson(map);

  Map<String, dynamic> toMap() => toJson();
}

@Freezed(copyWith: false)
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String orderId,
    required String customerId,
    required String vendorId,
    String? driverId,
    required List<OrderItem> items,
    required double totalAmount,
    required double deliveryFee,
    required OrderStatus status,
    required DeliveryAddress deliveryAddress,
    required String paymentMethod,
    @JsonKey(toJson: _dateTimetoJson, fromJson: _dateTimefromJson)
    required DateTime createdAt,
    @JsonKey(toJson: _dateTimetoJson, fromJson: _dateTimefromJson)
    required DateTime updatedAt,
  }) = _OrderModel;

  const OrderModel._();

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now().toIso8601String();
    return OrderModel.fromJson({
      'status': 'pending',
      'createdAt': now,
      'updatedAt': now,
      ...map,
    });
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toMap() => toJson();

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
      throw const ValidationException(
        message: 'Order must contain at least one item',
      );
    }
    for (final item in items) {
      if (item.quantity < 1 || item.quantity > 99) {
        throw const ValidationException(
          message: 'Item quantity must be between 1 and 99',
        );
      }
      if (item.price < 0) {
        throw const ValidationException(
          message: 'Item price cannot be negative',
        );
      }
    }
    final itemsTotal = items.fold<double>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    final expectedTotal = itemsTotal + deliveryFee;
    if ((totalAmount - expectedTotal).abs() > 0.01) {
      throw const ValidationException(
        message: 'Order total does not match items total plus delivery fee',
      );
    }
    if (totalAmount < 0) {
      throw const ValidationException(
        message: 'Total amount cannot be negative',
      );
    }
    if (deliveryFee < 0) {
      throw const ValidationException(
        message: 'Delivery fee cannot be negative',
      );
    }
    if (deliveryAddress.address.trim().isEmpty) {
      throw const ValidationException(
        message: 'Delivery address is required',
      );
    }
    if (deliveryAddress.name.trim().isEmpty) {
      throw const ValidationException(message: 'Recipient name is required');
    }
    if (deliveryAddress.phone.trim().isEmpty) {
      throw const ValidationException(message: 'Recipient phone is required');
    }
  }
}
