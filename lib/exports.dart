// Core Flutter & Material
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// Firebase
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';

// State Management & Navigation
export 'package:get/get.dart';

// UI Components
export 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
export 'package:carousel_slider/carousel_slider.dart';

// Utilities
export 'package:geolocator/geolocator.dart';
export 'package:phone_form_field/phone_form_field.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:flutter_map/flutter_map.dart';
export 'package:barcode_widget/barcode_widget.dart';
export 'package:image_picker/image_picker.dart';
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:get_storage/get_storage.dart';

// Project files
export 'firebase_options.dart';

// Core
export 'core/config.dart';
export 'core/utils/constants.dart';
export 'core/utils/themes.dart';
export 'core/utils/helpers.dart';
export 'core/services/firebase_service.dart';
export 'core/services/mapping_service.dart';
export 'core/services/scanning_service.dart';
export 'core/bindings/initial_binding.dart';

// Data
export 'data/models/user_model.dart';
export 'data/models/product_model.dart';
export 'data/models/cart_model.dart';
export 'data/models/order_model.dart';
export 'data/repositories/auth_repository.dart';
export 'data/repositories/product_repository.dart';
export 'data/repositories/cart_repository.dart';
export 'data/repositories/order_repository.dart';

// Routes
export 'routes/app_routes.dart';
export 'routes/app_pages.dart';

// Modules
export 'modules/auth/controllers/auth_controller.dart';
export 'modules/auth/views/login_view.dart';
export 'modules/auth/views/signup_view.dart';
export 'modules/auth/views/forgot_password_view.dart';

export 'modules/home/controllers/home_controller.dart';
export 'modules/home/views/home_view.dart';

export 'modules/cart/controllers/cart_controller.dart';
export 'modules/cart/views/cart_view.dart';
export 'modules/cart/views/checkout_view.dart';

export 'modules/profile/controllers/profile_controller.dart';
export 'modules/profile/views/profile_view.dart';

// Note: MapController from local module is available but not exported to avoid conflicts
export 'modules/map/views/map_view.dart';

export 'modules/order/controllers/order_history_controller.dart';
export 'modules/order/views/order_history_view.dart';

// Widgets
export 'widgets/common/custom_button.dart';
export 'widgets/common/custom_card.dart';
export 'widgets/common/custom_input.dart';
export 'widgets/layout/responsive_wrapper.dart';
