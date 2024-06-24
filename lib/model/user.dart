import '/exports.dart';

class UserModel {
  String id, name, email, image;
  String? password;
  PhoneNumber phone;
  GeoPoint? address;
  List<PromoCodeModel> promoCodes;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    this.password,
    required this.phone,
    this.address,
    required this.promoCodes,
  });

  factory UserModel.fromJson(DocumentSnapshot data) => UserModel(
        id: data.id,
        name: data['name'],
        phone: PhoneNumber.fromJson(data['phone']),
        email: data['email'],
        image: data['image'] ??
            'https://firebasestorage.googleapis.com/v0/b/alkhatib-market.appspot.com/o/no-profile-picture-icon.webp?alt=media&token=bfac8dae-344d-4cc9-b763-421a5c0d8988',
        address: data['address'],
        promoCodes: List<PromoCodeModel>.generate(
          data['promoCodes'].length,
          (index) => PromoCodeModel.fromJson(data['promoCodes'][index]),
        ),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
        'phone': phone.toJson(),
        'email': email,
        'address': address,
        'promoCodes': promoCodes.map((x) => x.toJson()).toList(),
      };
}

class PromoCodeModel {
  final String id;
  final double discont;

  PromoCodeModel({required this.id, required this.discont});

  factory PromoCodeModel.fromJson(Map data) => PromoCodeModel(
        id: data['id'],
        discont: double.parse(data['discont'].toString()),
      );

  Map<String, dynamic> toJson() => {'id': id, 'discont': discont};
}
