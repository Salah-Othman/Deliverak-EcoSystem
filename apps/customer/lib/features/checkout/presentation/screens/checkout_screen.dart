import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../../../orders/presentation/screens/order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String vendorId;

  const CheckoutScreen({super.key, required this.vendorId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _nameController.text = authState.user.name;
      _phoneController.text = authState.user.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          context.read<CartCubit>().clearCart();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: state.order.orderId),
            ),
            (route) => route.isFirst,
          );
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            if (cartState is! CartLoaded || cartState.items.isEmpty) {
              return const Center(
                child: Text('Your cart is empty'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(cartState),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDeliveryAddress(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPaymentMethod(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPlaceOrderButton(cartState),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Summary', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        ...state.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.name}',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  Text(
                    Formatters.currency(item.total),
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            )),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal', style: AppTypography.bodyMedium.copyWith(color: AppColors.grey600)),
            Text(Formatters.currency(state.totalAmount), style: AppTypography.bodyMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delivery fee', style: AppTypography.bodyMedium.copyWith(color: AppColors.grey600)),
            Text(Formatters.currency(state.deliveryFee), style: AppTypography.bodyMedium),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: AppTypography.titleLarge),
            Text(
              Formatters.currency(state.totalAmount + state.deliveryFee),
              style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Address', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: Validators.name,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          validator: (v) => Validators.required(v, 'Phone number'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Delivery Address',
            prefixIcon: Icon(Icons.location_on_outlined),
            alignLabelWithHint: true,
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter delivery address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: const Icon(Icons.money, color: AppColors.success),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cash on Delivery', style: AppTypography.titleMedium),
                    Text(
                      'Pay when your order arrives',
                      style: AppTypography.caption.copyWith(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: AppColors.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton(CartLoaded state) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        final isLoading = orderState is OrderLoading;

        return AppButton(
          label: isLoading
              ? 'Placing Order...'
              : 'Place Order - ${Formatters.currency(state.totalAmount + state.deliveryFee)}',
          isLoading: isLoading,
          onPressed: isLoading ? null : () => _placeOrder(state),
        );
      },
    );
  }

  void _placeOrder(CartLoaded cartState) {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return;

    final deliveryAddress = DeliveryAddress(
      lat: 0,
      lng: 0,
      address: _addressController.text.trim(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    context.read<OrderCubit>().createOrder(
          customerId: authState.user.uid,
          vendorId: widget.vendorId,
          items: cartState.items,
          totalAmount: cartState.totalAmount,
          deliveryFee: cartState.deliveryFee,
          deliveryAddress: deliveryAddress,
        );
  }
}
