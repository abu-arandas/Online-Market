# Online Market - Flutter Grocery Mobile App

Online Market is a Flutter-based grocery mobile application that allows users to browse, search, and purchase groceries online. The app integrates various features such as user authentication, real-time database, cloud storage, and geolocation to provide a seamless and efficient shopping experience.

## Features

- User Authentication (Firebase Auth)
- Real-time Database (Cloud Firestore)
- Image Upload and Storage (Firebase Storage)
- Responsive UI with Flutter Bootstrap 5
- State Management with GetX
- Geolocation Services
- Phone Number Input Form
- Product Carousel
- External URL Launching
- Interactive Maps
- Barcode Scanning and Generation
- Image Picker for Profile and Product Images

## Packages Used

- firebase_core
- firebase_auth
- cloud_firestore
- firebase_storage
- flutter_bootstrap5
- get
- geolocator
- phone_form_field
- carousel_slider
- url_launcher
- flutter_map
- barcode_widget
- image_picker

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase Project

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/abu-arandas/online-market.git
   ```
2. Navigate to the project directory:
   ```bash
   cd online-market
   ```
3. Install the dependencies:
   ```bash
   flutter pub get
   ```

### Firebase Setup

1. Set up a Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Add an Android and/or iOS app to the project.
3. Download the `google-services.json` file for Android and place it in the `android/app` directory.
4. Download the `GoogleService-Info.plist` file for iOS and place it in the `ios/Runner` directory.
5. Configure Firebase for the Flutter project by adding the necessary Firebase dependencies.

### Running the App

To run the app on an emulator or a physical device, use the following command:

```bash
flutter run
```

## Project Structure

```plaintext
lib/
├── main.dart
└── model/
├── controller/
└── view/
    └── page.dart
    └── widget.dart
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Submit a pull request.

## APK

[APK](assets/app.apk)

## Contact

For any inquiries or support, please contact [e00arandas@gmail.com](mailto:e00arandas@gmail.com).