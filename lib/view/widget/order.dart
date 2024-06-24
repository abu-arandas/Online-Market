import '/exports.dart';

class OrderWidget extends StatelessWidget {
  final String id;
  const OrderWidget({super.key, required this.id});

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: order(id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder(
              stream: offers(),
              builder: (context, offersSnapshot) {
                if (offersSnapshot.hasData) {
                  double total = 0;

                  for (var offer in offersSnapshot.data!) {
                    for (var product in snapshot.data!.products) {
                      if (offer.end.isBefore(DateTime.now()) &&
                          offer.start.isAfter(DateTime.now())) {
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

                  if (snapshot.data!.promoCode != null) {
                    total -=
                        (total * (snapshot.data!.promoCode!.discont / 100));
                  }

                  return ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetails(order: snapshot.data!),
                      ),
                    ),
                    leading: Icon(
                      Icons.circle,
                      color: progressColor(snapshot.data!.progress),
                    ),
                    title: Text(
                      snapshot.data!.id,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    subtitle: Text(
                      snapshot.data!.start.toString(),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    trailing: Text(
                      '${total.toStringAsFixed(2)} ${textString(TextString(en: 'JD', ar: 'د.أ'))}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Container();
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
