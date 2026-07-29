abstract class IAnalyticsService {
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters});

  Future<void> logLogin({required String method});

  Future<void> logLogout();

  Future<void> logSignUp({required String method});

  Future<void> logOrderPlaced({
    required String orderId,
    required String vendorId,
    required double totalAmount,
    required int itemCount,
  });

  Future<void> logOrderStatusChanged({
    required String orderId,
    required String oldStatus,
    required String newStatus,
  });

  Future<void> logOrderCancelled({
    required String orderId,
    required String reason,
  });

  Future<void> logVendorViewed({
    required String vendorId,
    required String vendorName,
  });

  Future<void> logProductViewed({
    required String productId,
    required String vendorId,
  });

  Future<void> logSearch({
    required String query,
    required String resultCount,
  });

  Future<void> logScreenView({required String screenName});

  Future<void> setUserProperty({required String name, required String? value});

  Future<void> setUserId({required String? userId});
}
