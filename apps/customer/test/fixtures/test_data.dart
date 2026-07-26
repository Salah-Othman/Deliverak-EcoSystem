import 'package:core/core.dart';

class TestData {
  TestData._();

  static final UserModel customer = UserModel(
    uid: 'test-customer-uid',
    name: 'John Doe',
    email: 'john@example.com',
    phone: '+1234567890',
    role: UserRole.customer,
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );

  static final UserModel emptyNameUser = UserModel(
    uid: 'test-new-uid',
    name: '',
    email: '',
    phone: '+1234567890',
    role: UserRole.customer,
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );

  static final VendorModel vendor = VendorModel(
    vendorId: 'vendor-1',
    name: 'Pizza Palace',
    description: 'Best pizza in town with authentic Italian flavors',
    image: 'https://example.com/pizza.jpg',
    category: DeliveryType.food,
    lat: 40.7128,
    lng: -74.0060,
    address: '123 Main St, New York, NY 10001',
    rating: 4.5,
    totalOrders: 150,
    isOpen: true,
    ownerId: 'owner-1',
    createdAt: DateTime.utc(2025, 1, 1),
  );

  static final VendorModel closedVendor = VendorModel(
    vendorId: 'vendor-2',
    name: 'Burger Barn',
    description: 'Juicy burgers and crispy fries',
    image: '',
    category: DeliveryType.food,
    lat: 40.7130,
    lng: -74.0062,
    address: '456 Oak Ave, New York, NY 10002',
    rating: 3.8,
    totalOrders: 75,
    isOpen: false,
    ownerId: 'owner-2',
    createdAt: DateTime.utc(2025, 1, 15),
  );

  static final ProductModel product = ProductModel(
    productId: 'product-1',
    vendorId: 'vendor-1',
    name: 'Margherita Pizza',
    description: 'Classic tomato, mozzarella, and basil',
    price: 12.99,
    images: ['https://example.com/margherita.jpg'],
    category: 'Pizza',
    isAvailable: true,
    createdAt: DateTime.utc(2025, 1, 1),
  );

  static final ProductModel discountedProduct = ProductModel(
    productId: 'product-2',
    vendorId: 'vendor-1',
    name: 'Pepperoni Pizza',
    description: 'Loaded with pepperoni',
    price: 15.99,
    discountPrice: 11.99,
    images: [],
    category: 'Pizza',
    isAvailable: true,
    createdAt: DateTime.utc(2025, 1, 1),
  );

  static final ProductModel unavailableProduct = ProductModel(
    productId: 'product-3',
    vendorId: 'vendor-1',
    name: 'Hawaiian Pizza',
    description: 'Ham and pineapple',
    price: 13.99,
    images: [],
    category: 'Specialty',
    isAvailable: false,
    createdAt: DateTime.utc(2025, 1, 1),
  );

  static OrderItem get orderItem => const OrderItem(
    productId: 'product-1',
    name: 'Margherita Pizza',
    quantity: 2,
    price: 12.99,
  );

  static DeliveryAddress get deliveryAddress => const DeliveryAddress(
    lat: 40.7128,
    lng: -74.0060,
    address: '123 Main St, New York, NY 10001',
    name: 'John Doe',
    phone: '+1234567890',
  );

  static final OrderModel order = OrderModel(
    orderId: 'order-12345678-abcd-efgh',
    customerId: 'test-customer-uid',
    vendorId: 'vendor-1',
    items: [orderItem],
    totalAmount: 25.98,
    deliveryFee: 2.99,
    status: OrderStatus.pending,
    deliveryAddress: deliveryAddress,
    paymentMethod: 'cash_on_delivery',
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );

  static final OrderModel deliveredOrder = OrderModel(
    orderId: 'order-delivered-123456',
    customerId: 'test-customer-uid',
    vendorId: 'vendor-1',
    items: [orderItem],
    totalAmount: 25.98,
    deliveryFee: 2.99,
    status: OrderStatus.delivered,
    deliveryAddress: deliveryAddress,
    paymentMethod: 'cash_on_delivery',
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 2),
  );

  static final NotificationModel notification = NotificationModel(
    notificationId: 'notif-1',
    userId: 'test-customer-uid',
    title: 'Order Confirmed',
    body: 'Your order #12345678 has been confirmed',
    type: 'order_confirmed',
    referenceId: 'order-12345678',
    isRead: false,
    createdAt: DateTime.utc(2025, 1, 1),
  );
}
