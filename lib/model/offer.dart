import '/exports.dart';

class OfferModel {
  String id;
  TextString title, description;
  String? image;
  double discont;
  DateTime start, end;
  List<String> products;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.discont,
    required this.start,
    required this.end,
    required this.products,
  });

  factory OfferModel.fromJson(DocumentSnapshot data) => OfferModel(
        id: data.id,
        title: TextString.fromJson(data['title']),
        description: TextString.fromJson(data['description']),
        image: data['image'],
        discont: 25,
        start: (data['start']).toDate(),
        end: (data['end']).toDate(),
        products: List<String>.from(data['products'].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        'title': title.toJson(),
        'description': description.toJson(),
        'image': image,
        'discont': discont,
        'start': start,
        'end': end,
        'products': products,
      };
}
