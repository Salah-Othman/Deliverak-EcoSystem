# Deliverak

A multi-vendor delivery marketplace for food, groceries, medicine, and packages. Built with Flutter, Firebase, and Cloudinary.

## Overview

Deliverak is a full delivery ecosystem consisting of four applications:

| App | Platform | Description |
|---|---|---|
| **Customer** | Android + iOS | Browse vendors, place orders, track deliveries |
| **Driver** | Android + iOS | Accept deliveries, live GPS navigation, earnings |
| **Vendor** | Android + iOS | Manage menu/products, handle orders |
| **Admin** | Flutter Web | Manage users, vendors, orders, analytics |

## Tech Stack

- **Flutter 3.x** — Cross-platform UI
- **Cubit (flutter_bloc)** — State management
- **GoRouter** — Navigation & routing
- **Firebase** — Backend (Auth, Firestore, Functions, FCM)
- **Cloudinary** — Image/file storage, CDN, transformations
- **Melos** — Monorepo management
- **Google Maps** — Live GPS tracking

## Project Structure

```
deliverak/
├── apps/
│   ├── customer/          # Customer mobile app
│   ├── driver/            # Driver/courier mobile app
│   ├── vendor/            # Vendor mobile app
│   └── admin/             # Admin panel (Flutter Web)
├── packages/
│   ├── core/              # Models, enums, constants, utils
│   ├── firebase_services/ # Firebase wrappers (Auth, Firestore, FCM)
│   ├── cloudinary_service/ # Cloudinary upload, transforms, CDN
│   ├── repositories/      # Data layer (Firestore CRUD)
│   ├── providers/         # Cubit state logic
│   └── ui_kit/            # Shared widgets, themes, assets
├── melos.yaml
└── plan.md
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Firebase project configured
- Cloudinary account (free tier) — [sign up](https://cloudinary.com)
- Google Maps API key
- Melos installed globally

### Installation

1. Clone the repository

```bash
git clone https://github.com/your-org/deliverak.git
cd deliverak
```

2. Install Melos and bootstrap

```bash
dart pub global activate melos
melos bootstrap
```

3. Configure Firebase for each app

```bash
cd apps/customer
flutterfire configure
```

4. Run an app

```bash
melos run customer:android    # Android
melos run customer:ios        # iOS
melos run admin:web           # Admin panel
```

## Features

### Customer App
- Phone OTP authentication
- Browse vendors by category (food, grocery, medicine, package)
- Search and filter vendors/products
- Cart management
- Cash on delivery ordering
- Live GPS delivery tracking
- Order history and reordering
- Push notifications

### Driver App
- Online/offline status toggle
- Accept/decline delivery requests
- Live GPS location streaming
- Order pickup and delivery confirmation
- Earnings and delivery history

### Vendor App
- Product/menu CRUD management
- Real-time order notifications
- Order status updates (accept, preparing, ready)
- Store open/close toggle
- Sales and order analytics

### Admin Panel
- User management (customers, drivers, vendors)
- Vendor approval and management
- Order monitoring and oversight
- Revenue and analytics dashboard
- Category management

## Firebase Services

| Service | Usage |
|---|---|
| Firebase Auth | Phone OTP authentication |
| Cloud Firestore | Real-time database for all entities |
| Cloud Functions | Server-side logic, FCM triggers |
| Cloud Messaging | Push notifications |

## Cloudinary (Image/File Storage)

| Feature | Free Tier |
|---|---|
| Storage | 25 GB |
| Bandwidth | 25 GB/month |
| Transformations | 25,000/month |
| CDN | Built-in global CDN |

## Configuration

### Environment Setup

Create `.env` files in each app:

```dart
// apps/customer/lib/config/env.dart
class Env {
  static const String googleMapsApiKey = 'YOUR_API_KEY';
  static const String projectId = 'deliverak-prod';
  static const String cloudinaryCloudName = 'YOUR_CLOUD_NAME';
  static const String cloudinaryUploadPreset = 'YOUR_UPLOAD_PRESET';
}
```

### Firebase Setup

Each app requires its own Firebase project configuration. Place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the respective app directories.

## Scripts (Melos)

```bash
melos run bootstrap          # Install all dependencies
melos run analyze            # Run dart analyze on all packages
melos run test               # Run tests across all packages
melos run format             # Format all Dart files
melos run customer:android   # Run customer app on Android
melos run customer:ios       # Run customer app on iOS
melos run admin:web          # Run admin panel on web
```

## Architecture

Each app follows a clean architecture pattern:

```
feature/
├── data/          # Repository implementations, data sources
├── domain/        # Models, repository interfaces
├── cubit/         # Cubit + State classes
└── presentation/  # Screens, widgets
```

See [plan.md](plan.md) for detailed architecture documentation.

## Roadmap

- [ ] Phase 1: Project setup, Auth, Profile
- [ ] Phase 2: Vendor listing, Product catalog
- [ ] Phase 3: Cart, Order placement
- [ ] Phase 4: Driver app, GPS tracking
- [ ] Phase 5: Vendor app, Order management
- [ ] Phase 6: Admin web panel
- [ ] Phase 7: Notifications, Polish, Testing

## License

Private — All rights reserved.
