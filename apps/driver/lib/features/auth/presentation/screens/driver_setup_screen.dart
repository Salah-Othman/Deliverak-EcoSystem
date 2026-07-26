import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class DriverSetupScreen extends StatefulWidget {
  const DriverSetupScreen({super.key});

  @override
  State<DriverSetupScreen> createState() => _DriverSetupScreenState();
}

class _DriverSetupScreenState extends State<DriverSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  String _selectedVehicleType = 'Motorcycle';

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<DriverCubit>().registerDriver(
            vehicleType: _selectedVehicleType,
            vehicleNumber: _vehicleNumberController.text.trim(),
            licenseNumber: _licenseNumberController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Vehicle Information',
                  style: AppTypography.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Please provide your vehicle details to start delivering',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                DropdownButtonFormField<String>(
                  initialValue: _selectedVehicleType,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Type',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Motorcycle',
                      child: Text('Motorcycle'),
                    ),
                    DropdownMenuItem(
                      value: 'Car',
                      child: Text('Car'),
                    ),
                    DropdownMenuItem(
                      value: 'Bicycle',
                      child: Text('Bicycle'),
                    ),
                    DropdownMenuItem(
                      value: 'Van',
                      child: Text('Van'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedVehicleType = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _vehicleNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Number',
                    hintText: 'ABC 1234',
                    prefixIcon: Icon(Icons.pin),
                  ),
                  validator: (v) => Validators.required(v, 'Vehicle number'),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _licenseNumberController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    hintText: 'DL-1234567890',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => Validators.required(v, 'License number'),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: AppSpacing.xl),
                BlocConsumer<DriverCubit, DriverState>(
                  listener: (context, state) {
                    if (state is DriverError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return AppButton(
                      label: 'Start Delivering',
                      onPressed: _submit,
                      isLoading: state is DriverLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
