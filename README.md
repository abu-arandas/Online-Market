# Online Market - Comprehensive Flutter E-commerce App

## 🚀 Overview

The Online Market app is a feature-rich Flutter e-commerce application built with modern architecture patterns and comprehensive functionality. This app demonstrates enterprise-level development practices with clean architecture, state management, and extensive user experience features.

## ✨ Features Implemented

### 🛍️ Core E-commerce Features
- **Product Catalog**: Browse products with categories and filters
- **Search & Discovery**: Advanced search with voice search capability
- **Shopping Cart**: Add/remove items with quantity management
- **Wishlist**: Save favorite products for later
- **Order Management**: Place orders and track delivery status
- **User Reviews**: Write and read product reviews with photos

### 🎨 User Experience
- **Onboarding**: Multi-step app introduction with permissions
- **Voice Search**: Speech-to-text search with intelligent processing
- **AR Preview**: Augmented reality product visualization (basic framework)
- **Real-time Notifications**: Push notifications and in-app alerts
- **Biometric Authentication**: Fingerprint and face ID login
- **Dark/Light Theme**: Customizable theme with color picker
- **Offline Support**: Cached data for offline browsing

### 🔧 Advanced Features
- **Payment Integration**: Multiple payment providers with Stripe
- **Order Tracking**: Real-time delivery tracking with timeline
- **A/B Testing**: Framework for feature experimentation
- **Internationalization**: Multi-language support (English/Spanish)
- **Analytics**: User behavior tracking and crash reporting
- **Performance**: Optimized with caching and background processing

### 🏗️ Technical Architecture
- **Clean Architecture**: Repository pattern with service layer
- **State Management**: GetX for reactive programming
- **Firebase Integration**: Authentication, messaging, analytics
- **Dependency Injection**: Proper service initialization
- **Error Handling**: Comprehensive error management
- **Testing**: Unit and widget test framework

## 📱 App Structure

```
lib/
├── core/                    # Core functionality
│   ├── services/           # Business logic services
│   ├── utils/              # Utilities and helpers
│   └── bindings/           # Dependency injection
├── data/                   # Data layer
│   ├── models/             # Data models
│   └── repositories/       # Data repositories
├── modules/                # Feature modules
│   ├── controllers/        # State management
│   └── views/              # UI screens
├── widgets/                # Reusable UI components
├── routes/                 # Navigation routing
└── l10n/                   # Internationalization
```

## 🔧 Services Implemented

### Core Services
- **FirebaseService**: Authentication and cloud functions
- **NotificationService**: Push and local notifications
- **CacheService**: Offline data management
- **BiometricService**: Fingerprint/face ID authentication
- **PaymentService**: Comprehensive payment processing
- **VoiceSearchService**: Speech recognition and processing
- **ARService**: Augmented reality framework
- **ABTestingService**: Feature experimentation

### Business Services
- **SearchService**: Advanced product search with filters
- **OrderTrackingService**: Real-time delivery tracking
- **MappingService**: Address and location services
- **ScanningService**: Barcode/QR code scanning

## 🎯 Key Controllers

- **SearchController**: Advanced search with voice input
- **ProductDetailController**: Product info with AR preview
- **WishlistController**: Favorite products management
- **NotificationController**: Alert management
- **OrderTrackingController**: Delivery status tracking
- **ThemeController**: Dynamic theming system
- **SettingsController**: App configuration
- **OnboardingController**: First-time user experience

## 📊 Data Models

- **ProductModel**: Product information and inventory
- **ReviewModel**: User reviews with photos
- **WishlistModel**: Saved products
- **NotificationModel**: Alert system
- **PromoCodeModel**: Discount management

## 🚦 Getting Started

### Prerequisites
- Flutter SDK 3.24.0+
- Dart 3.5.0+
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/online-market.git
   cd online-market
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Configure Firebase services (Auth, Firestore, FCM, Analytics)

4. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

1. **Environment Variables**
   Create `lib/core/config.dart` with your API keys:
   ```dart
   class Config {
     static const String stripePublishableKey = 'your_stripe_key';
     static const String firebaseApiKey = 'your_firebase_key';
     // Add other configuration
   }
   ```

2. **Firebase Configuration**
   - Enable Authentication (Email/Phone)
   - Set up Firestore database
   - Configure Cloud Messaging
   - Enable Analytics and Crashlytics

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/controllers/search_controller_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure
- **Unit Tests**: Controller and service logic
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end workflows

## 🚀 CI/CD Pipeline

The project includes GitHub Actions workflow for:
- **Automated Testing**: Run tests on every push
- **Code Analysis**: Flutter analyze and formatting checks
- **Build Verification**: APK and iOS builds
- **Deployment**: Firebase App Distribution

### Workflow File
`.github/workflows/ci-cd.yml` includes:
- Flutter environment setup
- Dependency installation
- Code formatting verification
- Static analysis
- Test execution
- Release builds
- Automated deployment

## 🌍 Internationalization

The app supports multiple languages:

### Supported Languages
- English (en)
- Spanish (es)

### Adding New Languages
1. Create new ARB file: `lib/l10n/app_[locale].arb`
2. Add translations for all keys
3. Update `l10n.yaml` configuration
4. Run `flutter gen-l10n`

## 📊 A/B Testing

The app includes a comprehensive A/B testing framework:

### Current Experiments
- **Checkout Button Color**: Blue vs Green vs Orange
- **Product Card Layout**: Compact vs Detailed
- **Search Suggestions**: Basic vs Enhanced

### Usage
```dart
final abService = Get.find<ABTestingService>();
final variant = abService.getVariant('experiment_id');
abService.trackConversion('experiment_id', 'button_click');
```

## 🔧 Development Tools

### Code Generation
```bash
# Generate localization files
flutter gen-l10n

# Generate JSON serialization
flutter packages pub run build_runner build
```

### Code Analysis
```bash
# Run static analysis
flutter analyze

# Check formatting
dart format --set-exit-if-changed .

# Fix formatting
dart format .
```

## 📱 Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Web**: Modern browsers with WebRTC support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the coding standards
4. Add tests for new features
5. Submit a pull request

### Coding Standards
- Follow Dart style guide
- Use meaningful variable names
- Add documentation for public APIs
- Maintain test coverage above 80%

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX community for state management
- Firebase for backend services
- All open source contributors

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Email: support@onlinemarket.app
- Documentation: [docs.onlinemarket.app]

---

**Built with ❤️ using Flutter**
