import '/exports.dart';

class ProductModel {
  String id, category, size;
  TextString title, description;
  double price;
  int stock;
  List<String> images;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.size,
    required this.price,
    required this.stock,
    required this.images,
  });

  factory ProductModel.fromJson(DocumentSnapshot json) => ProductModel(
        id: json.id,
        title: TextString.fromJson(json['title']),
        description: TextString.fromJson(json['description']),
        category: json['category'],
        size: json['size'],
        price: json['price']?.toDouble(),
        stock: int.parse(json['stock'].toString()),
        images: List<String>.from(json['images'].map((x) => x)),
      );

  factory ProductModel.fromMap(Map json) => ProductModel(
        id: json['id'],
        title: TextString.fromJson(json['title']),
        description: TextString.fromJson(json['description']),
        category: json['category'],
        size: json['size'],
        price: json['price']?.toDouble(),
        stock: int.parse(json['stock'].toString()),
        images: List<String>.from(json['images'].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title.toJson(),
        'description': description.toJson(),
        'category': category,
        'size': size,
        'price': price,
        'stock': stock,
        'images': List<String>.from(images.map((x) => x.toString())),
      };
}
