import '/exports.dart';

class ProductDetails extends StatelessWidget {
  final ProductModel productModel;
  const ProductDetails({super.key, required this.productModel});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: text(text: productModel.title),
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: product(productModel.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images
                    Container(
                      width: double.maxFinite,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(25),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(snapshot.data!.images.first),
                          fit: BoxFit.fill,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                            blurStyle: BlurStyle.outer,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 100,
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.images.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) => AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(
                                image: NetworkImage(
                                  snapshot.data!.images[index],
                                ),
                                fit: BoxFit.fill,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 5,
                                  blurStyle: BlurStyle.outer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.all(16).copyWith(top: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: text(
                              text: snapshot.data!.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          StreamBuilder(
                            stream: favorites(),
                            builder: (context, favoritesSnapshot) {
                              if (favoritesSnapshot.hasData) {
                                return IconButton(
                                  onPressed: () {
                                    DocumentReference id = FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .collection('favorites')
                                        .doc(productModel.id);

                                    if (favoritesSnapshot.data!
                                        .contains(productModel.id)) {
                                      id.delete();
                                    } else {
                                      id.set({});
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.grey.withOpacity(0.25),
                                  ),
                                  icon: Icon(
                                    favoritesSnapshot.data!
                                            .contains(snapshot.data!.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: favoritesSnapshot.data!
                                            .contains(snapshot.data!.id)
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                );
                              } else if (favoritesSnapshot.hasError) {
                                return Center(
                                  child:
                                      Text(favoritesSnapshot.error.toString()),
                                );
                              } else if (favoritesSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Size & Price
                    Padding(
                      padding: const EdgeInsets.all(16).copyWith(top: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              snapshot.data!.size,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          StreamBuilder(
                            stream: startedOffers(),
                            builder: (context, offersSnapshot) {
                              if (offersSnapshot.hasData) {
                                double price = snapshot.data!.price;

                                if (offersSnapshot.hasData) {
                                  for (var offer in offersSnapshot.data!) {
                                    if (offer.products
                                        .contains(snapshot.data!.id)) {
                                      price = snapshot.data!.price *
                                          (offer.discont / 100);
                                    }
                                  }
                                }

                                return GetBuilder<LanguageController>(
                                  builder: (controller) => Text(
                                    '${price.toStringAsFixed(2)} ${controller.language.languageCode == 'en' ? 'JO' : 'د.أ'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                );
                              } else if (offersSnapshot.hasError) {
                                return Center(
                                  child: Text(
                                    offersSnapshot.error.toString(),
                                  ),
                                );
                              } else if (offersSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Category
                    StreamBuilder(
                      stream: category(snapshot.data!.category),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            margin: const EdgeInsets.all(16).copyWith(top: 0),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12.5),
                            ),
                            child: text(
                              text: snapshot.data!.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),

                    // Description
                    Padding(
                      padding: const EdgeInsets.all(16).copyWith(top: 0),
                      child: text(text: snapshot.data!.description),
                    ),

                    // Cart
                    Container(
                      width: double.maxFinite,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.5),
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.25),
                      ),
                      child: GetBuilder<CartController>(
                        builder: (controller) => controller.cartProducts.any(
                                (element) => element.id == snapshot.data!.id)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (controller.cartProducts
                                              .singleWhere((element) =>
                                                  element.id ==
                                                  snapshot.data!.id)
                                              .stock >
                                          1) {
                                        controller.cartProducts
                                            .singleWhere((element) =>
                                                element.id == snapshot.data!.id)
                                            .stock--;
                                      } else {
                                        controller.cartProducts.removeWhere(
                                            (element) =>
                                                element.id ==
                                                snapshot.data!.id);
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
                                                  element.id ==
                                                  snapshot.data!.id)
                                              .stock++;

                                          controller.update();
                                        },
                                        borderRadius:
                                            BorderRadius.circular(12.5),
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
                    ),

                    // Related Products
                    StreamBuilder(
                      stream: products(),
                      builder: (context, productsSnapshot) {
                        if (productsSnapshot.hasData) {
                          List<ProductModel> products = productsSnapshot.data!
                              .where((element) =>
                                  element.category == snapshot.data!.category &&
                                  element.id != snapshot.data!.id)
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.all(16).copyWith(top: 0),
                                child: text(
                                  text: TextString(
                                    en: 'Related Products',
                                    ar: 'المنتجات المترابطة',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              FB5Row(
                                children: List.generate(
                                  products.length,
                                  (index) => FB5Col(
                                    classNames: 'col-6 col-md-4 col-lg-3 p-3',
                                    child: ProductWidget(
                                      id: products[index].id,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (productsSnapshot.hasError) {
                          return Center(
                            child: Text(
                              productsSnapshot.error.toString(),
                            ),
                          );
                        } else if (productsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Container();
              }
            },
          ),
        ),
      );
}
