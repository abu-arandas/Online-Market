import '/exports.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  TextString type = TextString(en: 'Ongoing', ar: 'الجاري حاليا');

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Tabs
          Container(
            width: double.maxFinite,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                tap(TextString(en: 'Ongoing', ar: 'الجاري حاليا')),
                const Text('  |  '),
                tap(TextString(en: 'History', ar: 'كل الطلبات')),
              ],
            ),
          ),

          // Orders
          StreamBuilder(
            stream: orders(),
            builder: (context, ordersSnapshot) {
              if (ordersSnapshot.hasData) {
                List<OrderModel> orders = ordersSnapshot.data!.where((element) {
                  if (type == TextString(en: 'Ongoing', ar: 'الجاري حاليا')) {
                    return element.progress == OrderProgress.preparing ||
                        element.progress == OrderProgress.delivering;
                  }

                  return true;
                }).toList();

                if (orders.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/empty-orders.png',
                          fit: BoxFit.fill,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          child: text(
                            text: TextString(
                              en: 'There is no ongoing order right now. You can order now',
                              ar: 'لا يوجد طلبات في الوقت الحالي. يمكنك اطلب الان',
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
                            fixedSize: const Size(500, 50),
                          ),
                          child: text(
                            text: TextString(
                              en: 'Order Now',
                              ar: 'اطلب الان',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    child: FB5Row(
                      children: List.generate(
                        orders.length,
                        (index) => FB5Col(
                          classNames: 'col-12 col-md-6 col-lg-4',
                          child: OrderWidget(id: orders[index].id),
                        ),
                      ),
                    ),
                  );
                }
              } else if (ordersSnapshot.hasError) {
                return Center(child: Text(ordersSnapshot.error.toString()));
              } else if (ordersSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Container();
              }
            },
          ),
        ],
      );

  Widget tap(TextString textString) => InkWell(
        onTap: () => setState(() => type = textString),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          decoration: type.en == textString.en
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12.5),
                  color: Theme.of(context).colorScheme.primary,
                )
              : BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12.5),
                ),
          child: text(
            text: textString,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: type.en == textString.en ? Colors.white : null,
            ),
          ),
        ),
      );
}
