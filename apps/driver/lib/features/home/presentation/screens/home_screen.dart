import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../available_orders/presentation/screens/available_orders_screen.dart';
import '../../../active_order/presentation/screens/active_order_screen.dart';
import '../../../earnings/presentation/screens/earnings_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _driverId;

  @override
  void initState() {
    super.initState();
    _loadDriver();
  }

  void _loadDriver() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<DriverCubit>().loadDriver();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverCubit, DriverState>(
      listener: (context, state) {
        if (state is DriverLoaded) {
          setState(() => _driverId = state.driver.driverId);
          context.read<DriverCubit>().watchDriver(state.driver.driverId);
          context
              .read<DriverOrderCubit>()
              .watchActiveOrder(state.driver.driverId);
        }
      },
      child: BlocBuilder<DriverCubit, DriverState>(
        builder: (context, state) {
          if (state is DriverLoading) {
            return const Scaffold(body: AppLoader());
          }

          if (state is DriverNotRegistered) {
            return const Scaffold(
              body: Center(
                child: Text('Please complete driver registration'),
              ),
            );
          }

          if (state is DriverLoaded) {
            final isOnline = state.driver.isOnline;
            return AdaptiveScaffold(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: const [
                NavigationItem(
                  icon: Icons.inbox_outlined,
                  activeIcon: Icons.inbox,
                  label: 'Orders',
                ),
                NavigationItem(
                  icon: Icons.local_shipping_outlined,
                  activeIcon: Icons.local_shipping,
                  label: 'Active',
                ),
                NavigationItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  label: 'Earnings',
                ),
                NavigationItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                ),
              ],
              appBar: AppBar(
                title: const Text('Deliverak Driver'),
                actions: [
                  _buildOnlineToggle(isOnline, state.driver.driverId),
                ],
              ),
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  const AvailableOrdersScreen(),
                  if (_driverId != null)
                    ActiveOrderScreen(driverId: _driverId!)
                  else
                    const Center(child: AppLoader()),
                  if (_driverId != null)
                    EarningsScreen(driverId: _driverId!)
                  else
                    const Center(child: AppLoader()),
                  const ProfileScreen(),
                ],
              ),
            );
          }

          if (state is DriverError) {
            return Scaffold(
              body: ErrorState(
                message: state.message,
                isRetryable: state.isRetryable,
                onRetry: _loadDriver,
              ),
            );
          }

          return const Scaffold(body: AppLoader());
        },
      ),
    );
  }

  Widget _buildOnlineToggle(bool isOnline, String driverId) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isOnline ? 'Online' : 'Offline',
            style: AppTypography.labelMedium.copyWith(
              color: isOnline ? AppColors.success : AppColors.grey500,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Switch(
            value: isOnline,
            onChanged: (_) {
              if (isOnline) {
                context.read<DriverCubit>().goOffline();
              } else {
                context.read<DriverCubit>().goOnline();
              }
            },
            activeThumbColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}
