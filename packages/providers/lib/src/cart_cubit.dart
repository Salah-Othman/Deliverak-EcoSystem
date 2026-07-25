import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final List<OrderItem> items;
  final double totalAmount;
  final double deliveryFee;

  const CartLoaded({
    required this.items,
    required this.totalAmount,
    required this.deliveryFee,
  });

  @override
  List<Object?> get props => [items, totalAmount, deliveryFee];
}

class CartCubit extends Cubit<CartState> {
  final List<OrderItem> _items = [];
  final double _deliveryFee = 2.99;

  CartCubit() : super(CartInitial());

  List<OrderItem> get items => List.unmodifiable(_items);
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.total);
  double get deliveryFee => _deliveryFee;
  double get grandTotal => totalAmount + deliveryFee;

  void addItem({
    required String productId,
    required String name,
    required double price,
    int quantity = 1,
  }) {
    final existingIndex = _items.indexWhere((item) => item.productId == productId);

    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = OrderItem(
        productId: productId,
        name: name,
        quantity: existing.quantity + quantity,
        price: price,
      );
    } else {
      _items.add(OrderItem(
        productId: productId,
        name: name,
        quantity: quantity,
        price: price,
      ));
    }

    _emitLoaded();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    _emitLoaded();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final item = _items[index];
      _items[index] = OrderItem(
        productId: productId,
        name: item.name,
        quantity: quantity,
        price: item.price,
      );
      _emitLoaded();
    }
  }

  void clearCart() {
    _items.clear();
    emit(CartInitial());
  }

  void _emitLoaded() {
    emit(CartLoaded(
      items: List.unmodifiable(_items),
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
    ));
  }
}
