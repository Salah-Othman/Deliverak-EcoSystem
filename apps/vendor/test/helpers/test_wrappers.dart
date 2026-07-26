import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:core/core.dart';
import 'package:providers/providers.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

Widget wrapWithApp({
  required Widget child,
  AuthCubit? authCubit,
  VendorOrderCubit? orderCubit,
  VendorProductCubit? productCubit,
  VendorProfileCubit? profileCubit,
}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(
          value: authCubit ?? MockAuthCubit(),
        ),
        if (orderCubit != null)
          BlocProvider<VendorOrderCubit>.value(value: orderCubit),
        if (productCubit != null)
          BlocProvider<VendorProductCubit>.value(value: productCubit),
        if (profileCubit != null)
          BlocProvider<VendorProfileCubit>.value(value: profileCubit),
      ],
      child: child,
    ),
  );
}

void setupMockAuthCubit(MockAuthCubit mockCubit, {UserRole role = UserRole.vendor}) {
  when(() => mockCubit.state).thenReturn(Authenticated(
    UserModel(
      uid: 'vendor-1',
      name: 'Test Vendor',
      email: 'vendor@test.com',
      phone: '+1234567890',
      role: role,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
  ));
  when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
}
