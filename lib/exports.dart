// ignore_for_file: depend_on_referenced_packages

export 'dart:ui'
    hide
        Gradient,
        decodeImageFromList,
        ImageDecoderCallback,
        StrutStyle,
        TextStyle,
        Image;

export 'package:flutter/material.dart';

export 'firebase_options.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';

export 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
export 'package:get/get.dart';
export 'package:geolocator/geolocator.dart';
export 'package:phone_form_field/phone_form_field.dart';
export 'package:carousel_slider/carousel_slider.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:flutter_map/flutter_map.dart';
export 'package:latlong2/latlong.dart' hide Path;
export 'package:barcode_widget/barcode_widget.dart';
export 'package:image_picker/image_picker.dart';

export 'controller/language.dart';
export 'controller/theme.dart';
export 'controller/firestore.dart';
export 'controller/home.dart';
export 'controller/address.dart';
export 'controller/cart.dart';
export 'controller/order.dart';

export 'model/text.dart';
export 'model/user.dart';
export 'model/product.dart';
export 'model/offer.dart';
export 'model/category.dart';
export 'model/order.dart';

export 'view/splash.dart';
export 'view/main.dart';

export 'view/page/authentication/login.dart';
export 'view/page/authentication/register.dart';
export 'view/page/authentication/reset.dart';

export 'view/page/home/home.dart';
export 'view/page/home/cart.dart';
export 'view/page/home/orders.dart';
export 'view/page/home/favorite.dart';
export 'view/page/home/product.dart';
export 'view/page/home/order.dart';
export 'view/page/home/shop.dart';
export 'view/page/home/offer.dart';

export 'view/widget/authentication_form.dart';
export 'view/widget/product.dart';
export 'view/widget/order.dart';


class EnumValues<T> {
  Map<String, T> map;
  late Map<T, dynamic> reverseMap;

  EnumValues(this.map);

  Map<T, dynamic> get reverse => map.map((k, v) => MapEntry(v, k));
}
