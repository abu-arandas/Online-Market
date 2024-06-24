import '/exports.dart';

class Shop extends StatelessWidget {
  const Shop({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
        builder: (controller) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Categories
              StreamBuilder(
                stream: categories(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          snapshot.data!.length,
                          (index) => InkWell(
                            borderRadius: BorderRadius.circular(12.5),
                            onTap: () {
                              controller.shpoCategoryId =
                                  snapshot.data![index].id;
                              controller.update();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 5,
                                    blurStyle: BlurStyle.outer,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  text(text: snapshot.data![index].title),
                                  if (controller.shpoCategoryId ==
                                      snapshot.data![index].id)
                                    IconButton(
                                      onPressed: () {
                                        controller.shpoCategoryId = null;
                                        controller.update();
                                      },
                                      icon: const Icon(Icons.close),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Container();
                  }
                },
              ),
              const SizedBox(height: 16),

              // Products
              StreamBuilder(
                stream: products(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<ProductModel> products = controller.shpoCategoryId !=
                            null
                        ? snapshot.data!
                            .where((product) =>
                                product.category == controller.shpoCategoryId)
                            .toList()
                        : snapshot.data!;

                    return FB5Row(
                      children: List.generate(
                        products.length,
                        (index) => FB5Col(
                          classNames: 'col-6 col-md-4 col-lg-3 p-3',
                          child: ProductWidget(
                            id: products[index].id,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      );
}
