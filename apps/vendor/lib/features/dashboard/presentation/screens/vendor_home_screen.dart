import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import 'dashboard_tab.dart';
import '../../../orders/presentation/screens/vendor_orders_screen.dart';
import '../../../menu/presentation/screens/product_list_screen.dart';
import '../../../profile/presentation/screens/store_profile_screen.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  int _currentIndex = 0;

  String get _vendorId {
    final state = context.read<AuthCubit>().state;
    if (state is Authenticated) return state.user.uid;
    return '';
  }

  @override
  void initState() {
    super.initState();
    final vendorId = _vendorId;
    if (vendorId.isNotEmpty) {
      context.read<VendorOrderCubit>().watchAllOrders(vendorId);
      context.read<VendorProfileCubit>().watchVendorProfile(vendorId);
      context.read<VendorProductCubit>().watchProducts(vendorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
      },
      items: const [
        NavigationItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'Dashboard',
        ),
        NavigationItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'Orders',
        ),
        NavigationItem(
          icon: Icons.restaurant_menu_outlined,
          activeIcon: Icons.restaurant_menu,
          label: 'Menu',
        ),
        NavigationItem(
          icon: Icons.store_outlined,
          activeIcon: Icons.store,
          label: 'Profile',
        ),
      ],
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DashboardTab(),
          const VendorOrdersScreen(),
          const ProductListScreen(),
          StoreProfileScreen(vendorId: _vendorId),
        ],
      ),
    );
  }
}
