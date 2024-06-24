import 'dart:math';

import '/exports.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: startedOffers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GetBuilder<CartController>(
              builder: (controller) {
                if (controller.cartProducts.isEmpty) {
                  return Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/empty_cart.png',
                          fit: BoxFit.fill,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          child: text(
                            text: TextString(
                              en: 'There is no products right now. You can order now',
                              ar: 'لا يوجد منتجات في الوقت الحالي. يمكنك الطلب الآن',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            HomeController.instance.changePage(1);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 32,
                            ),
                          ),
                          child: text(
                            text: TextString(
                              en: 'Explore the shop',
                              ar: 'تصفح المتجر',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  double total = 0;

                  for (var product in controller.cartProducts) {
                    for (var offer in snapshot.data!) {
                      if (offer.products.contains(product.id)) {
                        total += ((product.price -
                                (product.price * (offer.discont / 100))) *
                            product.stock);
                      } else {
                        total += (product.price * product.stock);
                      }

                      if (controller.promoCodeModel != null) {
                        total -= (total *
                            (controller.promoCodeModel!.discont / 100));
                      }
                    }
                  }

                  OrderModel order = OrderModel(
                    id: Random().nextInt(999999).toString(),
                    customer: FirebaseAuth.instance.currentUser!.uid,
                    start: DateTime.now(),
                    customerAddress: controller.address,
                    products: controller.cartProducts,
                    promoCode: controller.promoCodeModel,
                    progress: OrderProgress.preparing,
                  );

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Delivery Location
                        ...{
                          SizedBox(
                            height: 400,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: controller.address,
                                initialZoom: 15,
                                onMapEvent: (point) =>
                                    controller.setAddress(point.camera.center),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.arandas.online_market',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: controller.address,
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

                        // Products
                        ...{
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: text(
                              text: TextString(en: 'Products', ar: 'المنتجات'),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: FB5Row(
                              children: List.generate(
                                controller.cartProducts.length,
                                (index) => FB5Col(
                                  classNames:
                                      'col-lg-3 col-md-4 col-sm-6 col-xs-6 p-2 pt-0',
                                  child: ProductWidget(
                                      id: controller.cartProducts[index].id),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Divider(),
                          ),
                        },

                        // Price
                        ...{
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: text(
                              text: TextString(en: 'Price', ar: 'السعر'),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),

                          // Total
                          Container(
                            width: double.maxFinite,
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Row(
                              children: [
                                text(
                                  text: TextString(en: 'Total', ar: 'المجموع'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(total.toStringAsFixed(2)),
                                const SizedBox(width: 4),
                                text(text: TextString(en: 'JD', ar: 'دينار'))
                              ],
                            ),
                          ),

                          // Promo Code
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(
                                  text: TextString(
                                    en: 'Promo Codes',
                                    ar: 'رموز تروجي',
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => controller.promoCode(context),
                                  child: text(
                                    text: controller.promoCodeModel != null
                                        ? TextString(
                                            en: 'remove promo code',
                                            ar: 'ازالة الرمز التروجي',
                                          )
                                        : TextString(
                                            en: 'add promo code',
                                            ar: 'اضافة رمز تروجي',
                                          ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Divider(),
                          ),
                        },

                        // Payment Method
                        ...{
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: text(
                              text: TextString(
                                en: 'Payment Method',
                                ar: 'طريقة الدفع',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: 500,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.5),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.25),
                            ),
                            child: ListTile(
                              onTap: () =>
                                  controller.paymentType(context, null),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.monetization_on,
                                  color: Colors.white,
                                ),
                              ),
                              title: text(
                                text: controller
                                    .paymentDetails(controller.payment),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.all(4),
                                child: text(
                                  text: TextString(
                                    en: 'Tap Here to select your Payment Method',
                                    ar: 'اضغط هنا لتحديد طريقة الدفع',
                                  ),
                                  style: const TextStyle(height: 0.9),
                                ),
                              ),
                            ),
                          ),
                        },

                        // Divider
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Divider(),
                        ),

                        // Place Order
                        Container(
                          width: double.maxFinite,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16).copyWith(top: 0),
                          child: ElevatedButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(order.id)
                                  .set(order.toJson());

                              for (var product in controller.cartProducts) {
                                FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(product.id)
                                    .get()
                                    .then((item) {
                                  FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(product.id)
                                      .update({
                                    'stock': item['stock'] - product.stock
                                  });
                                });
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: text(
                                    text: TextString(
                                      en: 'Started',
                                      ar: 'تم البدأ',
                                    ),
                                  ),
                                ),
                              );

                              controller.cartProducts.clear();

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(250, 50),
                            ),
                            child: text(
                              text: TextString(en: 'Start', ar: 'بدأ'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
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
