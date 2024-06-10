import '/exports.dart';

class UserModel {
  String id, name, token;
  String? image;
  String phone;
  Roles role;
  bool available;
  Map<String, double>? address;
  List<PromoCodeModel> promoCodes;

  UserModel({
    required this.id,
    required this.name,
    this.image,
    required this.phone,
    required this.token,
    required this.role,
    required this.available,
    this.address,
    required this.promoCodes,
  });

  factory UserModel.fromJson(Map<String, dynamic> data) => UserModel(
        id: data['id'],
        name: data['name'],
        image: data['image'],
        phone: data['phone'],
        token: data['token'],
        role: roles.map[data['role']]!,
        available: data['available'],
        address: data['address'],
        promoCodes: List<PromoCodeModel>.from(
          data['promoCodes'].map((x) => PromoCodeModel.fromJson(x)),
        ),
      );
}

enum Roles { admin, employee, driver, client }

EnumValues<Roles> roles = EnumValues({
  'Admin': Roles.admin,
  'Driver': Roles.driver,
  'Employee': Roles.employee,
  'Client': Roles.client,
});

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
