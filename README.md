# 🛒 Online Market

[![Flutter](https://img.shields.io/badge/Flutter-3.0-blue?logo=flutter\&logoColor=white)](https://flutter.dev/)
[![GetX](https://img.shields.io/badge/GetX-State%20Mgmt-orange)](https://pub.dev/packages/get)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-yellow?logo=firebase)](https://firebase.google.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> “In a world of endless aisles, Online Market is your digital basket—ready to catch every craving.”

A Flutter-powered grocery shopping app that blends seamless UI with Firebase magic. Browse, scan, tap, and voilà—your cart’s full before you know it.

---

## 📖 Table of Contents

1. [✨ Features](#-features)
2. [🚀 Getting Started](#-getting-started)

   * [Prerequisites](#prerequisites)
   * [Installation & Setup](#installation--setup)
   * [Firebase Configuration](#firebase-configuration)
3. [👨‍💻 Project Structure](#-project-structure)
4. [⚙️ Usage](#%ef%b8%8f-usage)

   * [Running Locally](#running-locally)
   * [Building Release APK](#building-release-apk)
5. [🔧 Architecture & Tech Stack](#-architecture--tech-stack)
6. [🤝 Contributing](#-contributing)
7. [📬 Contact & Support](#-contact--support)
8. [📜 License](#-license)

---

## ✨ Features

* **🔐 Authentication**: Secure sign-in/sign-up with Firebase Auth (email & phone).
* **📦 Real-time Database**: Cloud Firestore for lightning-fast reads/writes.
* **📸 Media Handling**: Upload profile & product images to Firebase Storage.
* **📱 Responsive UI**: Built with Flutter Bootstrap 5 – mobile, tablet, and desktop ready.
* **⚡ State Management**: GetX for predictable and testable state & routing.
* **🗜️ Geolocation**: Pinpoint delivery addresses with interactive Google Maps.
* **📵 Phone Input**: International phone formatter and validation.
* **🎠 Product Carousel**: Eye-catching sliders for featured deals.
* **🔗 URL Launcher**: Open external vendor pages or support docs in a flash.
* **🔍 Barcode Tools**: Scan UPCs to add items, or generate barcodes for your inventory.
* **🖼️ Image Picker**: Native file selector for avatars & product shots.

---

## 🚀 Getting Started

### Prerequisites

* **Flutter SDK** ≥ 3.0
* **Dart** ≥ 2.18
* A **Firebase** account (Auth, Firestore, Storage).
* **Git** (for cloning).

### Installation & Setup

1. **Clone** this repo

   ```bash
   git clone https://github.com/abu-arandas/online-market.git
   cd online-market
   ```
2. **Get** Flutter packages

   ```bash
   flutter pub get
   ```
3. **Configure** your environment variables

   * Copy `.env.example` ➞ `.env`
   * Add your Firebase API keys, Google Maps key, etc.

### Firebase Configuration

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. **Add Apps**

   * **Android**: download `google-services.json` → place in `android/app/`
   * **iOS**: download `GoogleService-Info.plist` → place in `ios/Runner/`
3. Enable **Auth Providers** (Email, Phone).
4. Create **Firestore** rules and indexes as needed.
5. Enable **Storage** and set your security rules.

---

## 👨‍💻 Project Structure

```plaintext
lib/
├── main.dart             # App entrypoint & initial bindings
├── exports.dart          # Barrel file for cleaner imports
├── core/
│   ├── bindings/         # GetX dependency injections
│   ├── services/         # Firebase & mapping & scanning services
│   ├── utils/            # Constants, themes, helpers
│   └── config.dart       # Env configs & keys
├── data/
│   ├── models/           # User, Product, Cart, Order, etc.
│   └── repositories/     # Data-access & business logic
├── modules/
│   ├── auth/             # Login, Signup, Forgot Password
│   ├── home/             # Browse, Search, Carousel
│   ├── cart/             # Cart management & checkout
│   ├── profile/          # Account info & image picker
│   └── map/              # Geolocation & map views
├── routes/
│   ├── app_routes.dart   # Named routes
│   └── app_pages.dart    # GetPage definitions
└── widgets/
    ├── common/           # Buttons, Cards, Inputs
    └── layout/           # Responsive row/col wrappers
```

---

## ⚙️ Usage

### Running Locally

```bash
flutter run --flavor dev -t lib/main.dart
```

Keep an eye on your debug console—GetX logs are your best friend. 😉

### Building Release APK

```bash
flutter build apk --release --target-platform android-arm,android-arm64
```

Find your shiny `.apk` in `build/app/outputs/flutter-apk/`.

---

## 🔧 Architecture & Tech Stack

* **State & DI**: GetX (Bindings, Controllers, Reactive)
* **UI**: Flutter + Bootstrap 5 (via flutter\_bootstrap5)
* **Backend**: Firebase Auth, Firestore, Storage
* **Location**: Google Maps API
* **Barcode**: `barcode_scan2` & `barcode_widget`
* **Env Management**: `flutter_dotenv`

> *“A solid foundation today yields a framework for tomorrow’s growth.”*

---

## 🤝 Contributing

1. **Fork** the repo
2. **Branch** off `feature/your-feature-name`
3. **Commit** with clear messages
4. **Push** & open a **PR**
5. I’ll review ASAP—let’s make grocery shopping a breeze!

Please adhere to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).

---

## 📬 Contact & Support

**Author:** Arandas
**Email:** [e00arandas@gmail.com](mailto:e00arandas@gmail.com)
**Phone:** +962 7915 68798

Feel free to drop a line if you hit a snag or just want to chat about architectural poetry. 🌙

---

## 📜 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.
