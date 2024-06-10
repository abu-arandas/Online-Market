class TextString {
  String en, ar;

  TextString({required this.en, required this.ar});

  factory TextString.fromJson(Map data) =>
      TextString(en: data['en'], ar: data['ar']);

  Map toJson() => {'en': en, 'ar': ar};
}
