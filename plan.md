# Deliverak — Flutter Delivery Ecosystem Architecture Plan

## Project Overview

**Deliverak** is a multi-vendor delivery marketplace supporting food, groceries, packages, and medicine. Built with Flutter from zero to production-ready.

| Detail | Value |
|---|---|
| Type | Multi-vendor/marketplace |
| Delivery | Food, Grocery, Medicine, Packages |
| Platforms | Android + iOS (Mobile), Flutter Web (Admin) |
| Backend | Firebase (Auth, Firestore, Functions, FCM) + Cloudinary (Storage) |
| Payment | Cash on Delivery only |
| Tracking | Live GPS tracking |
| Notifications | FCM only |
| Team | Solo developer |
| State Mgmt | Cubit (flutter_bloc) |

---

## Tech Stack

| Layer | Choice | Reason |
|---|---|---|
| Framework | Flutter 3.x | Single codebase for Android + iOS |
| State Mgmt | **Cubit (flutter_bloc)** | Simple, predictable, BlocObserver for debugging |
| Navigation | **GoRouter** | Declarative, deep-link ready, role-based routing |
| Backend | **Firebase + Cloudinary** | Firebase: Auth, Firestore, Functions, FCM. Cloudinary: Image/file storage, CDN, transforms |
| Real-time | **Firestore Streams** | Live order status, GPS tracking |
| GPS | **geolocator + google_maps_flutter** | Location tracking + map display |
| Secure Storage | **flutter_secure_storage** | Encrypted local storage for tokens, sensitive data |
| Animations | **Built-in Flutter + shimmer** | Skeleton loading, micro-interactions, page transitions |
| Logging | **firebase_crashlytics** (optional) | Error tracking and crash reporting in production |
| Monorepo | **Melos** | Manage multiple apps + shared packages |
| Admin Panel | **Flutter Web** | Reuse shared code, same Dart ecosystem |

---

## Monorepo Structure

```
deliverak/
├── melos.yaml
├── apps/
│   ├── customer/          # Customer mobile app (Android + iOS)
│   ├── driver/            # Driver/courier mobile app (Android + iOS)
│   ├── vendor/            # Vendor mobile app (Android + iOS)
│   └── admin/             # Admin panel (Flutter Web)
├── packages/
│   ├── core/              # Models, enums, constants, utils
│   ├── firebase_services/ # Firestore, Auth, FCM wrappers
│   ├── repositories/      # Data layer (Firestore CRUD)
│   ├── providers/         # Cubit providers (state logic)
│   └── ui_kit/            # Shared widgets, themes, assets
```

---

## Layer Architecture (Per App)

```
lib/
├── main.dart
├── app/                   # App config, router, theme
├── config/                # Firebase init, environment, routes
├── features/              # Feature-based modules
│   ├── auth/
│   │   ├── data/          # Data sources, repository implementations
│   │   ├── domain/        # Models, repository interfaces
│   │   ├── cubit/         # Cubit + States
│   │   └── presentation/  # Screens, widgets
│   ├── home/
│   ├── orders/
│   ├── tracking/
│   ├── vendor_management/
│   └── notifications/
└── shared/                # App-level shared widgets
```

---

## Cubit Pattern

### State Definition

```dart
// auth_state.dart
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

### Cubit Implementation

```dart
// auth_cubit.dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> signInWithPhone(String phone) async {
    emit(AuthLoading());
    try {
      final user = await _repo.signInWithPhone(phone);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

### BlocObserver (Debugging)

```dart
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType}: $change');
  }
}
```

---

## Cubit Responsibilities Per Feature

| Feature | Cubit | Key Methods |
|---|---|---|
| **Auth** | `AuthCubit` | `signInWithPhone`, `verifyOtp`, `signOut`, `getCurrentUser` |
| **Vendors** | `VendorCubit` | `loadVendors`, `loadByCategory`, `searchVendors` |
| **Products** | `ProductCubit` | `loadProducts(vendorId)`, `loadByCategory` |
| **Cart** | `CartCubit` | `addItem`, `removeItem`, `updateQuantity`, `clearCart` |
| **Orders** | `OrderCubit` | `createOrder`, `loadOrders`, `cancelOrder` |
| **Order Status** | `OrderTrackingCubit` | `watchOrderStatus(orderId)` — stream-based |
| **Tracking** | `TrackingCubit` | `startTracking`, `stopTracking`, `updateLocation` |
| **Driver** | `DriverCubit` | `goOnline`, `acceptOrder`, `updateStatus`, `updateLocation` |
| **Vendor Orders** | `VendorOrderCubit` | `loadPending`, `acceptOrder`, `rejectOrder`, `markReady` |
| **Admin** | `AdminCubit` | `loadUsers`, `loadVendors`, `loadOrders`, `loadAnalytics` |
| **Notifications** | `NotificationCubit` | `loadNotifications`, `markAsRead` |

---

## Firebase Firestore Schema

```
users/
  {uid} → {
    name, email, phone,
    role: customer | driver | vendor | admin,
    fcmToken, profileImage,
    createdAt, updatedAt
  }

vendors/
  {vendorId} → {
    name, description, image,
    category: food | grocery | medicine | package,
    location: {lat, lng},
    address, rating, totalOrders,
    isOpen, ownerId,
    createdAt
  }

products/
  {productId} → {
    vendorId, name, description,
    price, discountPrice,
    images[], category,
    isAvailable, createdAt
  }

orders/
  {orderId} → {
    customerId, vendorId, driverId,
    items: [{productId, name, quantity, price}],
    totalAmount, deliveryFee,
    status: pending | accepted | preparing | picked_up | in_transit | delivered | cancelled,
    deliveryAddress: {lat, lng, address, name, phone},
    paymentMethod: cash,
    createdAt, updatedAt
  }

drivers/
  {driverId} → {
    userId, vehicleType, vehicleNumber,
    licenseNumber,
    isOnline, currentLocation: {lat, lng},
    rating, totalDeliveries,
    createdAt
  }

categories/
  {categoryId} → {
    name, image,
    type: food | grocery | medicine | package,
    sortOrder
  }

notifications/
  {notificationId} → {
    userId, title, body,
    type, referenceId,
    isRead, createdAt
  }
```

---

## Key Flows

### Customer Order Flow

1. Browse vendors → Filter by category → Select items
2. Add to cart → Place order (Cash on Delivery)
3. Order status: `pending` → FCM push to vendor
4. Vendor accepts → `accepted` → Driver sees available pickup
5. Driver picks up → `in_transit` → Live GPS tracking on customer app
6. Delivered → `delivered` → Customer confirms

### Live GPS Tracking

- Driver app streams location to Firestore `drivers/{driverId}.currentLocation` every 5 seconds
- Customer app listens to Firestore stream → updates map marker in real-time
- Uses `google_maps_flutter` for map display, `geolocator` for location access

### Cloud Functions

- `onOrderCreated` → Notify vendor via FCM
- `onOrderStatusChange` → Notify customer/driver via FCM
- `onDriverLocationUpdate` → (Optional) Clean old location data

---

## MVP Phases

| Phase | Features | Est. Time |
|---|---|---|
| **Phase 1** | Project setup, Monorepo, Firebase config, Auth (phone OTP), Role selection, Profile setup | 1-2 weeks |
| **Phase 2** | Vendor listing, Product catalog, Categories, Search & filters | 1-2 weeks |
| **Phase 3** | Cart, Order placement (Cash only), Order history | 1-2 weeks |
| **Phase 4** | Driver app: Order pickup, GPS tracking, Status updates, Earnings | 2 weeks |
| **Phase 5** | Vendor app: Order management, Menu/Product CRUD | 1 week |
| **Phase 6** | Admin web panel: Users, Vendors, Orders, Analytics dashboard | 2 weeks |
| **Phase 7** | Notifications (FCM), Security rules audit, Performance optimization, Error handling polish, Responsive/adaptive UI, Dark mode, Testing | 2-3 weeks |

**Total MVP Estimate: 12-15 weeks (solo dev)**

---

## Shared Packages Detail

### `core`
- Data models (UserModel, VendorModel, ProductModel, OrderModel, DriverModel)
- Enums (UserRole, OrderStatus, DeliveryType)
- Constants (Firestore paths, API constants)
- Utils (form validators, formatters, extensions)
- Custom exceptions (AppException, NetworkException, AuthException)
- Error code constants for consistent error mapping

### `firebase_services`
- FirebaseAuthService (phone auth, OTP)
- FirestoreService (CRUD operations, streams)
- FCMService (token management, local notifications)

### `cloudinary_service`
- CloudinaryService (image upload, delete, transform)
- Upload preset & folder management
- URL generation with transformations

### `repositories`
- AuthRepository
- VendorRepository
- ProductRepository
- OrderRepository
- DriverRepository
- NotificationRepository

### `ui_kit`
- App theme (Material 3 colors, typography scale, spacing system)
- Design tokens (colors.dart, typography.dart, spacing.dart, radius.dart)
- Common widgets (buttons, cards, dialogs, loaders)
- Adaptive widgets (AdaptiveScaffold, AdaptiveDialog, ResponsivePadding)
- Loading states (AppShimmer skeleton loader, progress indicators)
- State widgets (EmptyState, ErrorState with illustrations)
- Assets (images, icons, fonts)

---

## Key Decisions & Tradeoffs

1. **Separate apps per role vs. single app with role switching?**
   → Separate apps — cleaner builds, independent release cycles, smaller binary size

2. **Vendor app: Separate or inside Admin panel?**
   → Separate mobile app — vendors manage on-the-go

3. **Flutter Web for Admin?**
   → Yes — shared models/services, one ecosystem. Tradeoff: web perf is decent but not as snappy as React/Vue. Acceptable for admin.

4. **Cash only — no payment gateway?**
   → Simplifies MVP significantly. Can add Stripe/Razorpay later.

5. **Cubit over full BLoC?**
   → Simpler, less boilerplate. Events not needed for most cases. Easy to migrate to BLoC later if event-driven flow becomes necessary.

6. **Cloudinary over Firebase Storage?**
   → Firebase Storage removed from free Spark plan (Feb 2026). Cloudinary offers 25GB free storage + 25GB bandwidth/month with built-in CDN and image transformations. No credit card required for free tier.

---

## Security

### Firestore Security Rules

Role-based access control on every collection:

```
users/{uid}
  - read, write: if request.auth.uid == uid || request.auth.token.admin == true

vendors/{vendorId}
  - read: if true (public listing)
  - write: if request.auth.uid == resource.data.ownerId || request.auth.token.admin == true

products/{productId}
  - read: if true (public under vendor)
  - write: if request.auth.uid == get(/databases/$(database)/documents/vendors/$(resource.data.vendorId)).data.ownerId

orders/{orderId}
  - read, write: if request.auth.uid in [resource.data.customerId, resource.data.vendorId, resource.data.driverId]
                 || request.auth.token.admin == true

drivers/{driverId}
  - read: if true (for matching)
  - write: if request.auth.uid == resource.data.userId || request.auth.token.admin == true

notifications/{notificationId}
  - read, write: if request.auth.uid == resource.data.userId
```

### Input Validation

**Client-side** (immediate feedback):
- Phone number: E.164 format validation before OTP request
- Profile fields: max length (name: 50, address: 200)
- Price/quantity: non-negative, max bounds (quantity: 1–99, price: 0–999999)
- Product description: max 1000 characters

**Server-side** (Cloud Functions — authoritative):
- Order total must match sum of (item.price × item.quantity) + deliveryFee
- Driver can only update status for orders assigned to them
- Vendor can only modify products under their vendorId
- Status transitions must follow valid sequence (no skip from pending to delivered)

### Secure Storage

- `flutter_secure_storage` for: FCM tokens, cached auth state, sensitive user data
- Never store passwords or full payment info (cash-only, but future-proof)

### API Key Management

- All keys in `lib/config/env.dart` — never hardcoded in source
- Cloudinary upload presets are unsigned (safe for client-side)
- Firebase config files (`google-services.json`, `GoogleService-Info.plist`) in `.gitignore`

### Cloud Functions Security

- Validate order totals server-side before writing to Firestore
- Verify driver assignment before allowing status updates
- Rate limit OTP requests (max 5 per phone number per hour)
- Sanitize all user-provided strings before storage

---

## Error Handling

### Global Error Handler

In `main.dart` — catches all uncaught errors:

```dart
void main() {
  FlutterError.onError = (details) {
    // Log to Crashlytics in release, debugPrint in debug
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };

  runApp(const DeliverakApp());
}
```

### Standardized Cubit Error States

Every Cubit follows this pattern:

```dart
// order_state.dart
abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}
class OrderLoading extends OrderState {}
class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;
  OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}
class OrderError extends OrderState {
  final String message;
  final String? code;
  final bool isRetryable;
  OrderError({required this.message, this.code, this.isRetryable = false});
  @override
  List<Object?> get props => [message, code, isRetryable];
}
```

### Error Mapping

Translate technical exceptions to user-friendly messages:

| Exception | Code | User Message | Retryable |
|---|---|---|---|
| `network-request-failed` | `network` | "No internet connection. Check your network." | Yes |
| `quota-exceeded` | `quota` | "Storage limit reached. Contact support." | No |
| `permission-denied` | `permission` | "You don't have access to this." | No |
| `document-not-found` | `not_found` | "Item not found." | No |
| `timeout` | `timeout` | "Request timed out. Please try again." | Yes |
| Unknown | `unknown` | "Something went wrong. Please try again." | Yes |

### Retry Logic

For transient errors (network timeout, Firestore unavailable):

```dart
Future<T> retryWithBackoff<T>(Future<T> Function() action, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await action();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 1 * (1 << i))); // 1s, 2s, 4s
    }
  }
  throw UnreachableError();
}
```

- Show "Retry" button on `OrderError(isRetryable: true)`
- Auto-retry Firestore stream reconnection
- Never silently swallow errors

### Graceful Degradation

- **Offline**: Show cached Firestore data (enable offline persistence)
- **Network unavailable**: Disable network-dependent actions, show tooltip
- **Image load failure**: Show placeholder asset, not broken image
- **Never crash** — always fallback to a safe UI state

---

## Performance Optimization

### Image Optimization

- Always use Cloudinary URL transformations: `w_300,h_300,c_fill,q_auto,f_auto`
- `cached_network_image` with 100MB disk cache for all network images
- Lazy load images below the fold using `ListView.builder`
- Thumbnail-first: load small preview (`w_100,h_100`), full image on tap
- Compress camera captures before upload (max 1920px, quality 85)

### Firestore Query Optimization

- **Composite indexes** for common queries:
  - `vendors`: `category` + `isOpen`
  - `orders`: `customerId` + `createdAt` (descending)
  - `orders`: `vendorId` + `status`
  - `orders`: `driverId` + `status`
- **Pagination** with `limit()` + `startAfterDocument()` on all lists
- Use `snapshots()` only where real-time is needed; otherwise `get()` with cache
- Select only needed fields where Firestore supports it
- Avoid `collectionGroup` queries unless absolutely necessary

### Widget Performance

- `const` constructors everywhere possible
- `RepaintBoundary` around expensive widgets (maps, animated lists, charts)
- Never call `setState` in build methods — Cubit state only
- `ListView.builder` for all dynamic lists (never `ListView(children: [...])`)
- Set `cacheExtent` on scrollable lists for smoother scrolling
- Use `Select` / `BlocSelector` to minimize Cubit rebuilds to relevant state slices

### Memory Management

- `dispose()` all StreamSubscriptions, AnimationControllers, TextEditingControllers
- Cancel Firestore stream listeners when leaving screen
- Use `AutomaticKeepAliveClientMixin` sparingly (only tabs that justify it)
- Limit concurrent image downloads (cache handles queuing)

### Map & GPS Performance

- Throttle location updates to Firestore (every 5 seconds, not every frame)
- Use `MarkerId` to update existing markers instead of recreating
- Dispose map controller on screen dispose
- Reduce map tile quality on low-end devices if needed
- Pause location updates when app is in background

---

## Responsive & Adaptive UI

### Layout Strategy

Root `LayoutBuilder` on every screen that needs responsiveness:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 1024) return _DesktopLayout();
    if (constraints.maxWidth > 600) return _TabletLayout();
    return _MobileLayout();
  },
)
```

### Breakpoints

| Category | Width Range |
|---|---|
| Mobile | 0–599px |
| Tablet | 600–1023px |
| Desktop/Web | 1024px+ |

### Adaptive Widgets (in `ui_kit`)

- `AdaptiveScaffold` — Bottom navigation on mobile, sidebar on tablet/desktop
- `AdaptiveListTile` — Single column on mobile, multi-column on wider screens
- `AdaptiveDialog` — Bottom sheet on mobile, dialog on desktop
- `ResponsivePadding` — Compact on mobile (16px), generous on desktop (32–48px)
- `ResponsiveGridView` — 2 columns mobile, 3 tablet, 4 desktop

### Orientation

- Support both portrait and landscape on: Home, Vendor listing, Order history, Cart
- Lock to portrait only on: Camera screens, OTP input, Payment confirmation
- Use `OrientationBuilder` for grid column counts

### Safe Areas

- `SafeArea` wrapper on every screen
- Handle notch/punch-hole cameras (top padding)
- Bottom nav spacer for gesture navigation (iPhone home indicator)

### Keyboard Handling

- `FocusTraversalGroup` for logical tab order on forms
- `KeyboardDismissBehavior.onDrag` on scrollable screens
- `Scaffold.resizeToAvoidBottomInset: true` on all form screens

### Web (Admin Panel)

- Wider content containers (max-width: 1200px, centered)
- Sidebar navigation (not bottom nav)
- Hover states on all interactive elements (buttons, rows, cards)
- Table-based layouts for data-heavy screens (orders, users, vendors)
- Sticky header with search/filters

---

## Modern UI Design

### Material 3 / Material You

- `ThemeData(useMaterial3: true, colorSchemeSeed: AppColors.primary)`
- Dynamic color on Android 12+ (respect user system preference)
- Consistent elevation, shape, and color using Material 3 tokens

### Design Tokens

Defined in `packages/ui_kit/lib/theme/`:

```
colors.dart     — Primary, secondary, surface, error, success, warning, neutral shades
typography.dart — Display (32sp), Headline (24sp), Title (18sp), Body (16sp), Label (14sp), Caption (12sp)
spacing.dart    — xs(4), sm(8), md(16), lg(24), xl(32), xxl(48)
radius.dart     — sm(8), md(12), lg(16), xl(24), full(999)
```

All widget spacing, sizing, and colors reference these tokens — no hardcoded values.

### Dark Mode

- Full dark theme alongside light theme (both defined in `app_theme.dart`)
- Store user preference in `shared_preferences`
- System-default as initial setting
- Every color defined for both light and dark themes
- No hardcoded colors in any widget

### Animations & Transitions

- **Page transitions**: `FadeThrough` for bottom nav tabs, `SharedAxis` for hierarchical navigation
- **Micro-interactions**: Button press scale (0.95), card tap elevation change (0→2dp)
- **State transitions**: `AnimatedSwitcher` for loading → content → error
- **List animations**: Staggered entry for home screen items (100ms delay per item)
- Keep animations under 300ms for snappy feel

### Loading States

- **Skeleton/shimmer** (`shimmer` package) for all list items and cards during initial load
- **Linear progress bar** for uploads and multi-step processes
- **Circular progress indicator** for single actions (button press)
- No full-screen spinners — always show context (e.g., skeleton card layout)

### Empty & Error States

- Custom illustrations for: no orders, no vendors nearby, network error, empty cart
- **Actionable empty states**: "Browse vendors" button when cart is empty
- **Consistent error widget**: `ErrorState` component with message + retry button
- Match illustration style across all states (consistent visual language)

### Typography Scale

| Level | Size | Weight | Usage |
|---|---|---|---|
| Display | 32sp | Bold | Hero sections, splash |
| Headline | 24sp | SemiBold | Screen titles |
| Title | 18sp | Medium | Section headers |
| Body | 16sp | Regular | Content text |
| Label | 14sp | Medium | Buttons, chips, tabs |
| Caption | 12sp | Regular | Timestamps, secondary info |

---

## Packages (pubspec.yaml — key dependencies)

```yaml
dependencies:
  flutter_bloc: ^8.x
  equatable: ^2.x
  go_router: ^14.x
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x
  firebase_messaging: ^15.x
  firebase_crashlytics: ^4.x
  cloudinary_flutter: ^3.x
  cloudinary: ^1.x
  geolocator: ^13.x
  google_maps_flutter: ^2.x
  dio: ^5.x
  intl: ^0.19.x
  cached_network_image: ^3.x
  flutter_local_notifications: ^18.x
  flutter_secure_storage: ^9.x
  shared_preferences: ^2.x
  shimmer: ^3.x
  url_launcher: ^6.x
  share_plus: ^10.x
```

---

## Cloudinary Setup

### Why Cloudinary?

Firebase Cloud Storage was removed from the free Spark plan in February 2026. Cloudinary provides a generous free tier with no credit card required.

| Feature | Free Tier |
|---|---|
| Storage | 25 GB |
| Bandwidth | 25 GB/month |
| Transformations | 25,000/month |
| CDN | Built-in global CDN |
| Image Transforms | Auto-resize, crop, format conversion on-the-fly |

### Setup Steps

1. Create a free account at [cloudinary.com](https://cloudinary.com)
2. Get your **Cloud Name** and **Upload Preset** from the dashboard
3. Create upload presets for each use case:
   - `deliverak_products` — Product images
   - `deliverak_vendors` — Vendor/store images
   - `deliverak_profiles` — User profile pictures
   - `deliverak_delivery` — Delivery proof photos

### Usage in Flutter

```dart
// Upload product image
final cloudinary = CloudinaryPublic('your_cloud_name', 'deliverak_products', cache: true);

CloudinaryResponse response = await cloudinary.uploadFile(
  CloudinaryFile.fromFile(filePath, folder: 'products'),
);

// Store response.secureUrl in Firestore
await FirebaseFirestore.instance.collection('products').doc(productId).update({
  'images': FieldValue.arrayUnion([response.secureUrl]),
});
```

```dart
// Display with auto-optimization
CloudinaryImage(
  'https://res.cloudinary.com/xxx/image/upload/w_300,h_300,c_fill/products/item.jpg',
  width: 300,
  height: 300,
)
```

### Image Transformation URL Examples

```
// Thumbnail (100x100)
https://res.cloudinary.com/{cloud}/image/upload/w_100,h_100,c_fill/{path}

// Medium (400x400, auto quality)
https://res.cloudinary.com/{cloud}/image/upload/w_400,h_400,q_auto/{path}

// Original with auto-format (WebP, AVIF)
https://res.cloudinary.com/{cloud}/image/upload/f_auto,q_auto/{path}
```

---

## Directory Structure — Full Example (Customer App)

```
apps/customer/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── app_bloc_provider.dart
│   │   ├── routes/
│   │   │   └── app_router.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       └── app_colors.dart
│   ├── config/
│   │   ├── firebase_options.dart
│   │   └── env.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/repositories/auth_repository.dart
│   │   │   ├── domain/models/user_model.dart
│   │   │   ├── cubit/
│   │   │   │   ├── auth_cubit.dart
│   │   │   │   └── auth_state.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   └── otp_screen.dart
│   │   │       └── widgets/
│   │   ├── home/
│   │   │   ├── data/repositories/vendor_repository.dart
│   │   │   ├── domain/models/vendor_model.dart
│   │   │   ├── cubit/
│   │   │   │   ├── vendor_cubit.dart
│   │   │   │   └── vendor_state.dart
│   │   │   └── presentation/
│   │   │       ├── screens/home_screen.dart
│   │   │       └── widgets/
│   │   │           ├── vendor_card.dart
│   │   │           └── category_chips.dart
│   │   ├── cart/
│   │   │   ├── cubit/
│   │   │   │   ├── cart_cubit.dart
│   │   │   │   └── cart_state.dart
│   │   │   └── presentation/
│   │   │       ├── screens/cart_screen.dart
│   │   │       └── widgets/
│   │   ├── orders/
│   │   │   ├── data/repositories/order_repository.dart
│   │   │   ├── domain/models/order_model.dart
│   │   │   ├── cubit/
│   │   │   │   ├── order_cubit.dart
│   │   │   │   ├── order_state.dart
│   │   │   │   ├── order_tracking_cubit.dart
│   │   │   │   └── order_tracking_state.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── orders_screen.dart
│   │   │       │   └── order_detail_screen.dart
│   │   │       └── widgets/
│   │   ├── tracking/
│   │   │   ├── cubit/
│   │   │   │   ├── tracking_cubit.dart
│   │   │   │   └── tracking_state.dart
│   │   │   └── presentation/
│   │   │       └── screens/tracking_screen.dart
│   │   ├── profile/
│   │   └── notifications/
│   └── shared/
│       ├── widgets/
│       │   ├── app_button.dart
│       │   ├── app_card.dart
│       │   ├── app_loader.dart
│       │   ├── app_shimmer.dart
│       │   ├── app_dialog.dart
│       │   ├── empty_state.dart
│       │   ├── error_state.dart
│       │   └── adaptive_scaffold.dart
│       └── utils/
│           ├── formatters.dart
│           ├── validators.dart
│           └── error_handler.dart
├── pubspec.yaml
└── analysis_options.yaml
```

---

*Last updated: July 26, 2026*
