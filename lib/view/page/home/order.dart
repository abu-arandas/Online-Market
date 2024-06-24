import '/exports.dart';

class OrderDetails extends StatelessWidget {
  final OrderModel order;
  const OrderDetails({super.key, required this.order});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: text(
            text: TextString(en: 'Order #${order.id}', ar: 'طلب #${order.id}'),
          ),
          actions: [
            // Delete Button
            if (order.progress == OrderProgress.preparing ||
                order.progress == OrderProgress.delivering)
              IconButton.filled(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('orders')
                      .doc(order.id)
                      .delete();

                  HomeController.instance.changePage(0);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xffdc3545),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete),
              )
          ],
        ),
        body: StreamBuilder(
          stream: offers(),
          builder: (context, offersSnapshot) {
            if (offersSnapshot.hasData) {
              double total = 0;

              for (var offer in offersSnapshot.data!) {
                for (var product in order.products) {
                  if (offer.end.isBefore(order.start) &&
                      offer.start.isAfter(order.start)) {
                    if (offer.products.contains(product.id)) {
                      total += ((product.price -
                              (product.price * (offer.discont / 100))) *
                          product.stock);
                    } else {
                      total += (product.price * product.stock);
                    }
                  } else {
                    total += (product.price * product.stock);
                  }
                }
              }

              if (order.promoCode != null) {
                total = total - (total * (order.promoCode!.discont / 100));
              }

              Widget progress(BuildContext context, OrderProgress progress) =>
                  Expanded(
                    child: Container(
                      height: 2,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.5),
                        color: order.progress == OrderProgress.deleted
                            ? const Color(0xffdc3545)
                            : int.parse(orderProgress
                                        .reverse[order.progress]) >=
                                    int.parse(orderProgress.reverse[progress])
                                ? progressColor(order.progress)
                                : Colors.grey,
                      ),
                    ),
                  );

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Delivery Location
                    ...{
                      SizedBox(
                        height: 400,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: order.customerAddress,
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.arandas.online_market',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: order.customerAddress,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    },

                    // Informations
                    Container(
                      width: 500,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress
                          ...{
                            Container(
                              width: double.maxFinite,
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: text(
                                text: progressDetails(order.progress),
                                style: TextStyle(
                                  color: progressColor(order.progress),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  progress(
                                    context,
                                    OrderProgress.preparing,
                                  ),
                                  const SizedBox(width: 16),
                                  progress(
                                    context,
                                    OrderProgress.delivering,
                                  ),
                                  const SizedBox(width: 16),
                                  progress(
                                    context,
                                    OrderProgress.done,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          },

                          // QR Code
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 500,
                              padding: const EdgeInsets.all(16),
                              child: BarcodeWidget(
                                barcode: Barcode.code93(),
                                data: order.id,
                                height: 75,
                              ),
                            ),
                          ),

                          // Time
                          ...{
                            text(
                              text: TextString(
                                en: 'Time',
                                ar: 'الوقت',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(
                                  text: TextString(
                                    en: 'Start',
                                    ar: 'البدأ',
                                  ),
                                ),
                                Text(
                                  order.start.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: Colors.red),
                                ),
                              ],
                            ),
                            if (order.pick != null)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  text(
                                    text: TextString(
                                      en: 'Pick',
                                      ar: 'الاستلام',
                                    ),
                                  ),
                                  Text(
                                    order.pick!.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: Colors.red),
                                  ),
                                ],
                              ),
                            if (order.deliver != null)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  text(
                                    text: TextString(
                                      en: 'Finish',
                                      ar: 'التوصيل',
                                    ),
                                  ),
                                  Text(
                                    order.deliver!.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: Colors.red),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 24),
                          },

                          // Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text(
                                text: TextString(
                                  en: 'Price',
                                  ar: 'السعر',
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${total.toStringAsFixed(2)} ${LanguageController.instance.language.languageCode == 'en' ? 'JD' : 'د.أ'}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Cash on derivery
                          if (order.payment == PaymentType.cash) ...{
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: text(
                                text: TextString(
                                  en: 'Cash on derivery has some potential risks of spreading contamination. You can select other payment methods for a contactless safe delivery.',
                                  ar: 'الدفع عند الاستلام على بعض المخاطر المحتملة لنشر التلوث. يمكنك تحديد طرق دفع أخرى للتسليم الآمن بدون تلامس.',
                                ),
                              ),
                            )
                          },

                          // Divider
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(thickness: 1),
                          ),
                        ],
                      ),
                    ),

                    // Products
                    FB5Row(
                      children: List.generate(
                        order.products.length,
                        (index) => FB5Col(
                          classNames: 'col-12 col-md-6 col-lg-4 p-3',
                          child: product(
                            context: context,
                            order: order,
                            productModel: order.products[index],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget product({
    required BuildContext context,
    required OrderModel order,
    required ProductModel productModel,
  }) =>
      Container(
        constraints: const BoxConstraints(maxHeight: 125),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              blurStyle: BlurStyle.outer,
            )
          ],
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            if (productModel.images.isNotEmpty)
              Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxWidth: 100),
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      blurStyle: BlurStyle.outer,
                    )
                  ],
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.25),
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(12.5),
                    bottomStart: Radius.circular(12.5),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(productModel.images.first),
                    fit: BoxFit.fill,
                  ),
                ),
              ),

            // Informations
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    text(
                      text: productModel.title,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Size & Price
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(productModel.size),
                        const Spacer(),
                        const Text('  |  '),
                        const Spacer(),
                        ProductPrice(
                          productModel: productModel,
                          stock: productModel.stock,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
