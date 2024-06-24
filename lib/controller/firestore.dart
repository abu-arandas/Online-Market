import 'dart:async';

import '/exports.dart';

Stream<UserModel> user() => FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .snapshots()
    .map((query) => UserModel.fromJson(query));

Stream<List<String>> favorites() => FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('favorites')
    .snapshots()
    .map((query) => query.docs.map((item) => item.id).toList());

Stream<List<OfferModel>> offers() =>
    FirebaseFirestore.instance.collection('offers').snapshots().map((query) =>
        query.docs.map((item) => OfferModel.fromJson(item)).toList());

Stream<List<OfferModel>> startedOffers() => FirebaseFirestore.instance
    .collection('offers')
    .snapshots()
    .map((query) => query.docs
        .map((item) => OfferModel.fromJson(item))
        .where((element) =>
            element.start.isBefore(DateTime.now()) &&
            element.end.isAfter(DateTime.now()))
        .toList());

Stream<OfferModel> offer(String id) => FirebaseFirestore.instance
    .collection('offers')
    .doc(id)
    .snapshots()
    .map((query) => OfferModel.fromJson(query));

Stream<List<OrderModel>> orders() => FirebaseFirestore.instance
    .collection('orders')
    .snapshots()
    .map((query) => query.docs
        .map((item) => OrderModel.fromJson(item))
        .where((element) =>
            element.customer == FirebaseAuth.instance.currentUser!.uid)
        .toList());

Stream<OrderModel> order(String id) => FirebaseFirestore.instance
    .collection('orders')
    .doc(id)
    .snapshots()
    .map((query) => OrderModel.fromJson(query));

Stream<List<CategoryModel>> categories() => FirebaseFirestore.instance
    .collection('categories')
    .snapshots()
    .map((query) =>
        query.docs.map((item) => CategoryModel.fromJson(item)).toList());

Stream<CategoryModel> category(String id) => FirebaseFirestore.instance
    .collection('categories')
    .doc(id)
    .snapshots()
    .map((query) => CategoryModel.fromJson(query));

Stream<List<ProductModel>> products() =>
    FirebaseFirestore.instance.collection('products').snapshots().map((query) =>
        query.docs.map((item) => ProductModel.fromJson(item)).toList());

List<ProductModel> bestSelling({
  required List<OrderModel> ordersData,
  required List<ProductModel> productsData,
}) {
  List<Map<String, dynamic>> ordersProducts = [];

  for (var order in ordersData) {
    for (var product in order.products) {
      if (ordersProducts.any((element) => element['id'] == product.id)) {
        ordersProducts.singleWhere(
            (element) => element['id'] == product.id)['stock'] += product.stock;
      } else {
        ordersProducts.add({
          'id': product.id,
          'stock': product.stock,
        });
      }
    }
  }

  if (ordersData.isNotEmpty) {
    return productsData
        .where((product) =>
            ordersProducts.any((element) => element['id'] == product.id))
        .toList();
  } else {
    return productsData;
  }
}

Stream<ProductModel> product(String id) => FirebaseFirestore.instance
    .collection('products')
    .doc(id)
    .snapshots()
    .map((query) => ProductModel.fromJson(query));
