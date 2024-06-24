import '/exports.dart';

class OfferDetails extends StatelessWidget {
  final OfferModel offerModel;
  const OfferDetails({super.key, required this.offerModel});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: text(
            text: TextString(en: 'Offers', ar: 'العروض'),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations
              Container(
                width: double.maxFinite,
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12.5),
                  ),
                  image: offerModel.image != null
                      ? DecorationImage(
                          image: NetworkImage(offerModel.image!),
                          fit: BoxFit.fill,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.5),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: Theme.of(context).appBarTheme.toolbarHeight,
                    ),
                    text(
                      text: offerModel.title,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                    ),
                    text(
                      text: offerModel.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Products
              FB5Row(
                children: List.generate(
                  offerModel.products.length,
                  (index) => FB5Col(
                    classNames: 'col-6 col-md-4 col-lg-3 p-3',
                    child: ProductWidget(
                      id: offerModel.products[index],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
