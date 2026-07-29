// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  productId: json['productId'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'quantity': instance.quantity,
      'price': instance.price,
    };

_DeliveryAddress _$DeliveryAddressFromJson(Map<String, dynamic> json) =>
    _DeliveryAddress(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$DeliveryAddressToJson(_DeliveryAddress instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'address': instance.address,
      'name': instance.name,
      'phone': instance.phone,
    };

_OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => _OrderModel(
  orderId: json['orderId'] as String,
  customerId: json['customerId'] as String,
  vendorId: json['vendorId'] as String,
  driverId: json['driverId'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  deliveryFee: (json['deliveryFee'] as num).toDouble(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  deliveryAddress: DeliveryAddress.fromJson(
    json['deliveryAddress'] as Map<String, dynamic>,
  ),
  paymentMethod: json['paymentMethod'] as String,
  createdAt: _dateTimefromJson(json['createdAt'] as String),
  updatedAt: _dateTimefromJson(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderModelToJson(_OrderModel instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'customerId': instance.customerId,
      'vendorId': instance.vendorId,
      'driverId': instance.driverId,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'totalAmount': instance.totalAmount,
      'deliveryFee': instance.deliveryFee,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'deliveryAddress': instance.deliveryAddress.toJson(),
      'paymentMethod': instance.paymentMethod,
      'createdAt': _dateTimetoJson(instance.createdAt),
      'updatedAt': _dateTimetoJson(instance.updatedAt),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.accepted: 'accepted',
  OrderStatus.preparing: 'preparing',
  OrderStatus.pickedUp: 'pickedUp',
  OrderStatus.inTransit: 'inTransit',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};
