import '/exports.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
        builder: (controller) => StreamBuilder(
          stream: products(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search
                    Autocomplete<ProductModel>(
                      displayStringForOption: (ProductModel option) =>
                          textString(option.title),
                      fieldViewBuilder: (context, fieldTextEditingController,
                              fieldFocusNode, onFieldSubmitted) =>
                          Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          style: Theme.of(context).textTheme.bodySmall,
                          decoration: InputDecoration(
                            hintText: textString(
                              TextString(en: 'Search...', ar: 'بحث...'),
                            ),
                            hintStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            prefixIcon: const Icon(Icons.search, size: 32),
                          ),
                        ),
                      ),
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<ProductModel>.empty();
                        } else if (snapshot.hasData) {
                          return snapshot.data!.where(
                            (ProductModel option) => textString(option.title)
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()),
                          );
                        } else {
                          return const Iterable<ProductModel>.empty();
                        }
                      },
                      onSelected: (ProductModel selection) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetails(productModel: selection),
                        ),
                      ),
                    ),

                    // Offers
                    StreamBuilder(
                      stream: startedOffers(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isNotEmpty) {
                            return CarouselSlider.builder(
                              itemCount: snapshot.data!.length,
                              options: CarouselOptions(
                                height: 200,
                                viewportFraction: 1,
                                enableInfiniteScroll: false,
                                autoPlay:
                                    snapshot.data!.length.isGreaterThan(1),
                              ),
                              itemBuilder: (context, index, realIndex) =>
                                  Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.5),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 5,
                                        blurStyle: BlurStyle.outer,
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OfferDetails(
                                          offerModel: snapshot.data![index],
                                        ),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Image
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.75,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              image:
                                                  snapshot.data![index].image !=
                                                          null
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                            snapshot
                                                                .data![index]
                                                                .image!,
                                                          ),
                                                          fit: BoxFit.fill,
                                                        )
                                                      : null,
                                              borderRadius:
                                                  BorderRadius.circular(12.5),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.25),
                                            ),
                                          ),
                                        ),

                                        // Details
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.5,
                                            height: 300,
                                            padding: const EdgeInsets.all(32),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                text(
                                                  text: snapshot
                                                      .data![index].title,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                text(
                                                  text: TextString(
                                                    en: 'Grap ${snapshot.data![index].discont}%',
                                                    ar: 'احصل علي ${snapshot.data![index].discont}%',
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          return Container();
                        }
                      },
                    ),

                    // Categories
                    ...{
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            text(
                              text:
                                  TextString(en: 'Categories', ar: 'التصنيفات'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => controller.changePage(1),
                              child: text(
                                text:
                                    TextString(en: 'View All', ar: 'عرض الكل'),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            )
                          ],
                        ),
                      ),
                      StreamBuilder(
                        stream: categories(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: List.generate(
                                  snapshot.data!.length,
                                  (index) => InkWell(
                                    borderRadius: BorderRadius.circular(12.5),
                                    onTap: () {
                                      controller.shpoCategoryId =
                                          snapshot.data![index].id;

                                      controller.changePage(1);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(7.5),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black,
                                            blurRadius: 5,
                                            blurStyle: BlurStyle.outer,
                                          ),
                                        ],
                                      ),
                                      child: text(
                                        text: snapshot.data![index].title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(snapshot.error.toString()));
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return Container();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                    },

                    // Products
                    ...{
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            text(
                              text: TextString(
                                en: 'Best selling',
                                ar: 'الأكثر مبيعا',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => controller.changePage(1),
                              child: text(
                                text:
                                    TextString(en: 'View All', ar: 'عرض الكل'),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            )
                          ],
                        ),
                      ),
                      StreamBuilder(
                        stream: orders(),
                        builder: (context, ordersSnapshot) {
                          if (ordersSnapshot.hasData) {
                            List<ProductModel> products = bestSelling(
                              ordersData: ordersSnapshot.data!,
                              productsData: snapshot.data!,
                            );

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: FB5Row(
                                children: List.generate(
                                  products.length,
                                  (index) => FB5Col(
                                    classNames:
                                        'col-lg-3 col-md-4 col-sm-6 col-xs-6 p-2 pt-0',
                                    child: ProductWidget(
                                      id: products[index].id,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else if (ordersSnapshot.hasError) {
                            return Center(
                                child: Text(ordersSnapshot.error.toString()));
                          } else if (ordersSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    },
                  ],
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
        ),
      );
}
