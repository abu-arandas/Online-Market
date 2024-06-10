export 'dart:ui'
    hide
        Gradient,
        decodeImageFromList,
        ImageDecoderCallback,
        StrutStyle,
        TextStyle,
        Image;

export 'package:flutter/material.dart';

export 'package:get/get.dart';
export 'package:phone_form_field/phone_form_field.dart';

export 'controller/language.dart';
export 'controller/theme.dart';
export 'controller/authentication.dart';

export 'model/text.dart';
export 'model/user.dart';

export 'page/splash.dart';
export 'page/home.dart';

export 'page/authentication/main.dart';

export 'widget/authentication/form.dart';
export 'widget/authentication/login.dart';
export 'widget/authentication/register.dart';
export 'widget/authentication/reset.dart';


class EnumValues<T> {
  Map<String, T> map;
  late Map<T, dynamic> reverseMap;

  EnumValues(this.map);

  Map<T, dynamic> get reverse => map.map((k, v) => MapEntry(v, k));
}
