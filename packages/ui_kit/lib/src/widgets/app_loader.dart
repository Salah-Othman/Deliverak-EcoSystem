import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoader({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

class AppFullScreenLoader extends StatelessWidget {
  const AppFullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppLoader(),
    );
  }
}
