import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final String? code;
  final bool isRetryable;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.code,
    this.isRetryable = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Oops! Something went wrong',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.grey700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
            if (code != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Error code: $code',
                style: AppTypography.caption.copyWith(
                  color: AppColors.grey400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (isRetryable && onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
