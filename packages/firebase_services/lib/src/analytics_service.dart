import 'package:core/core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService implements IAnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters?.cast<String, Object>());
  }

  @override
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  @override
  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  @override
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  @override
  Future<void> logOrderPlaced({
    required String orderId,
    required String vendorId,
    required double totalAmount,
    required int itemCount,
  }) async {
    await _analytics.logPurchase(
      currency: 'SAR',
      value: totalAmount,
      items: [
        AnalyticsEventItem(itemId: vendorId, itemName: 'order'),
      ],
    );
    await _analytics.logEvent(
      name: 'order_placed',
      parameters: {
        'order_id': orderId,
        'vendor_id': vendorId,
        'total_amount': totalAmount,
        'item_count': itemCount,
      },
    );
  }

  @override
  Future<void> logOrderStatusChanged({
    required String orderId,
    required String oldStatus,
    required String newStatus,
  }) async {
    await _analytics.logEvent(
      name: 'order_status_changed',
      parameters: {
        'order_id': orderId,
        'old_status': oldStatus,
        'new_status': newStatus,
      },
    );
  }

  @override
  Future<void> logOrderCancelled({
    required String orderId,
    required String reason,
  }) async {
    await _analytics.logEvent(
      name: 'order_cancelled',
      parameters: {
        'order_id': orderId,
        'reason': reason,
      },
    );
  }

  @override
  Future<void> logVendorViewed({
    required String vendorId,
    required String vendorName,
  }) async {
    await _analytics.logEvent(
      name: 'vendor_viewed',
      parameters: {
        'vendor_id': vendorId,
        'vendor_name': vendorName,
      },
    );
  }

  @override
  Future<void> logProductViewed({
    required String productId,
    required String vendorId,
  }) async {
    await _analytics.logEvent(
      name: 'product_viewed',
      parameters: {
        'product_id': productId,
        'vendor_id': vendorId,
      },
    );
  }

  @override
  Future<void> logSearch({
    required String query,
    required String resultCount,
  }) async {
    await _analytics.logSearch(searchTerm: query);
  }

  @override
  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> setUserId({required String? userId}) async {
    await _analytics.setUserId(id: userId);
  }
}
