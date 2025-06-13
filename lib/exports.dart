// Core Flutter & Material
export 'package:flutter/material.dart' hide SearchController;
export 'package:flutter/services.dart';

// Firebase
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';
export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:firebase_analytics/firebase_analytics.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';

// State Management & Navigation
export 'package:get/get.dart';

// UI Components
export 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
export 'package:carousel_slider/carousel_slider.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:shimmer/shimmer.dart';
export 'package:flutter_rating_bar/flutter_rating_bar.dart' hide RatingWidget;

// Voice & Speech
export 'package:speech_to_text/speech_to_text.dart';
export 'package:flutter_tts/flutter_tts.dart';

// Utilities
export 'package:geolocator/geolocator.dart';
export 'package:phone_form_field/phone_form_field.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:flutter_map/flutter_map.dart';
export 'package:barcode_widget/barcode_widget.dart';
export 'package:image_picker/image_picker.dart';
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:flutter_local_notifications/flutter_local_notifications.dart';
export 'package:flutter_dotenv/flutter_dotenv.dart';
export 'package:share_plus/share_plus.dart';
export 'package:local_auth/local_auth.dart';
export 'package:crypto/crypto.dart';
export 'package:intl/intl.dart' hide TextDirection;
export 'package:device_info_plus/device_info_plus.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:path_provider/path_provider.dart';
export 'package:sqflite/sqflite.dart' hide Transaction;
export 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
export 'dart:io' hide HeaderValue;

// Project files
export 'firebase_options.dart';

// Core
export 'core/config.dart';
export 'core/utils/helpers.dart';
export 'core/utils/themes.dart';

// Services
export 'core/services/services.dart';

// Bindings
export 'core/bindings/initial_binding.dart';

// Data
export 'data/data.dart';

// Routes
export 'routes/app_routes.dart';
export 'routes/app_pages.dart';

// Modules
export 'modules/modules.dart';

// Widgets
export 'widgets/widgets.dart';
