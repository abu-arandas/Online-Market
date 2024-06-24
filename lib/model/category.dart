import '/exports.dart';

class CategoryModel {
  String id;
  TextString title;

  CategoryModel({required this.id, required this.title});

  factory CategoryModel.fromJson(DocumentSnapshot data) => CategoryModel(
        id: data.id,
        title: TextString.fromJson(data['title']),
      );

  Map<String, dynamic> toJson() => {'title': title.toJson()};
}
