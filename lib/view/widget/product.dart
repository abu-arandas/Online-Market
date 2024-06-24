import '/exports.dart';

class ProductWidget extends StatelessWidget {
  final String id;
  const ProductWidget({super.key, required this.id});

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: product(id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5,
                    blurStyle: BlurStyle.outer,
                  ),
                ],
                borderRadius: BorderRadius.circular(12.5),
              ),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetails(productModel: snapshot.data!),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.5),
                          image: DecorationImage(
                            image: NetworkImage(snapshot.data!.images.first),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: text(
                        text: snapshot.data!.title,
                        maxLines: 2,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Price
                    ProductPrice(productModel: snapshot.data!),
                    const SizedBox(height: 8),

                    // Cart
                    GetBuilder<CartController>(
                      builder: (controller) => controller.cartProducts
                              .any((element) => element.id == snapshot.data!.id)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (controller.cartProducts
                                            .singleWhere((element) =>
                                                element.id == snapshot.data!.id)
                                            .stock >
                                        1) {
                                      controller.cartProducts
                                          .singleWhere((element) =>
                                              element.id == snapshot.data!.id)
                                          .stock--;
                                    } else {
                                      controller.cartProducts.removeWhere(
                                          (element) =>
                                              element.id == snapshot.data!.id);
                                    }

                                    controller.update();
                                  },
                                  borderRadius: BorderRadius.circular(12.5),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(controller.cartProducts
                                      .singleWhere((element) =>
                                          element.id == snapshot.data!.id)
                                      .stock
                                      .toString()),
                                ),
                                if (controller.cartProducts
                                        .singleWhere((element) =>
                                            element.id == snapshot.data!.id)
                                        .stock <
                                    snapshot.data!.stock)
                                  AnimatedOpacity(
                                    opacity: controller.cartProducts
                                                .singleWhere((element) =>
                                                    element.id ==
                                                    snapshot.data!.id)
                                                .stock <
                                            snapshot.data!.stock
                                        ? 1
                                        : 0,
                                    duration: const Duration(seconds: 1),
                                    child: InkWell(
                                      onTap: () {
                                        controller.cartProducts
                                            .singleWhere((element) =>
                                                element.id == snapshot.data!.id)
                                            .stock++;

                                        controller.update();
                                      },
                                      borderRadius: BorderRadius.circular(12.5),
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.add,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : ElevatedButton.icon(
                              onPressed: () {
                                controller.cartProducts.add(ProductModel(
                                  id: snapshot.data!.id,
                                  title: snapshot.data!.title,
                                  description: snapshot.data!.description,
                                  category: snapshot.data!.category,
                                  size: snapshot.data!.size,
                                  price: snapshot.data!.price,
                                  stock: 1,
                                  images: snapshot.data!.images,
                                ));

                                controller.update();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                fixedSize: const Size(500, 50),
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.transparent,
                              ),
                              icon: const Icon(Icons.shopping_cart),
                              label: text(
                                text: TextString(
                                  en: 'Add to Cart',
                                  ar: 'اضافة الى العربة',
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Container();
          }
        },
      );
}

class ProductPrice extends StatelessWidget {
  final ProductModel productModel;
  final int? stock;
  const ProductPrice({
    super.key,
    required this.productModel,
    this.stock,
  });

  @override
  Widget build(BuildContext context) => GetBuilder<LanguageController>(
        builder: (controller) => StreamBuilder(
          stream: startedOffers(),
          builder: (context, offersSnapshot) {
            if (offersSnapshot.hasData) {
              double price = productModel.price;
              bool discounted = false;

              if (offersSnapshot.hasData) {
                for (var offer in offersSnapshot.data!) {
                  if (offer.products.contains(productModel.id)) {
                    price = productModel.price -
                        (productModel.price * (offer.discont / 100));
                    discounted = true;
                  }
                }
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    productModel.price.toStringAsFixed(2),
                    style: discounted
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          )
                        : null,
                  ),
                  if (discounted) Text(price.toStringAsFixed(2)),
                  const SizedBox(width: 4),
                  text(text: TextString(en: 'JD', ar: 'دينار')),
                  if (stock != null) ...{
                    const SizedBox(width: 4),
                    Text('*$stock'),
                  }
                ],
              );
            } else if (offersSnapshot.hasError) {
              return Center(child: Text(offersSnapshot.error.toString()));
            } else if (offersSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Container();
            }
          },
        ),
      );
}
