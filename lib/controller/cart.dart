import '/exports.dart';

class CartController extends GetxController {
  static CartController instance = Get.find();

  RxList<ProductModel> cartProducts = <ProductModel>[].obs;

  LatLng address = AddressController.instance.currentAddress;
  void setAddress(LatLng address) {
    this.address = address;
    update();
  }

  PromoCodeModel? promoCodeModel;
  void promoCode(context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: text(text: TextString(en: 'Promo Codes', ar: 'رموز تروجي')),
          content: StreamBuilder(
            stream: user(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.promoCodes.isNotEmpty) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    snapshot.data!.promoCodes.length,
                    (index) => ListTile(
                      onTap: () {
                        promoCodeModel =
                            (promoCodeModel == snapshot.data!.promoCodes[index]
                                ? snapshot.data!.promoCodes[index]
                                : null);

                        update();

                        Navigator.pop(context);
                      },
                      title: Text(snapshot.data!.promoCodes[index].id),
                      subtitle:
                          Text('${snapshot.data!.promoCodes[index].discont} %'),
                      trailing: Icon(
                        promoCodeModel == snapshot.data!.promoCodes[index]
                            ? Icons.remove_circle
                            : LanguageController
                                        .instance.language.languageCode ==
                                    'en'
                                ? Icons.keyboard_arrow_right
                                : Icons.keyboard_arrow_left,
                      ),
                    ),
                  ),
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/sorry.png'),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: text(
                        text: TextString(
                          en: 'sorry you don\'t have a promo code',
                          ar: 'للاسف لا يوجد لديك رمز ترويجي',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      );

  PaymentType payment = PaymentType.cash;

  TextString paymentDetails(PaymentType payment) {
    switch (payment) {
      case PaymentType.cash:
        return TextString(
          en: 'Cash on deliver',
          ar: 'الدفع عند التوصيل',
        );
      case PaymentType.creditcard:
        return TextString(
          en: 'Paid by Credit Card',
          ar: 'تم الدفع عن طريق البطاقة الائتمانية',
        );
    }
  }

  void paymentType(context, OrderModel? order) {
    GlobalKey<FormState> formKey = GlobalKey();
    TextEditingController cardHolderName = TextEditingController();
    TextEditingController cardNumber = TextEditingController();
    TextEditingController cvvCode = TextEditingController();
    TextEditingController expiryDate = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () => Navigator.pop(context),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      text: TextString(en: 'Payment', ar: 'طرق الدفع'),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GetBuilder<CartController>(
                  builder: (controller) => Column(
                    children: [
                      // Cash on Deliver
                      ListTile(
                        onTap: () {
                          if (order != null) {
                          } else {
                            controller.payment = PaymentType.cash;
                            controller.update();
                          }

                          Navigator.pop(context);
                        },
                        leading: const Icon(Icons.monetization_on),
                        title: text(
                          text: TextString(
                            en: 'Cash on deliver',
                            ar: 'الدفع عند الاستلام',
                          ),
                        ),
                        trailing: Radio(
                          value: PaymentType.cash,
                          groupValue: order != null
                              ? order.payment
                              : controller.payment,
                          onChanged: (value) {},
                        ),
                      ),

                      // Credit Card
                      Form(
                        key: formKey,
                        child: ExpansionTile(
                          leading: const Icon(Icons.payment),
                          title: text(
                            text: TextString(
                              en: 'Credit Card',
                              ar: 'بطاقة الائتمان',
                            ),
                          ),
                          trailing: Radio(
                            value: PaymentType.creditcard,
                            groupValue: order != null
                                ? order.payment
                                : controller.payment,
                            onChanged: (value) {},
                          ),
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Card Number',
                                hintText: 'XXXX XXXX XXXX XXXX',
                              ),
                              controller: cardNumber,
                              keyboardType: TextInputType.number,
                              autofillHints: const <String>[
                                AutofillHints.creditCardNumber
                              ],
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                if (value.length == 16) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '*';
                                } else if (value.length != 16) {
                                  return '*';
                                }

                                return null;
                              },
                            ),

                            // Expired Date & CVV
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  // Expired Date
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Expired Date',
                                        hintText: 'XX/XX',
                                      ),
                                      controller: expiryDate,
                                      keyboardType: TextInputType.number,
                                      autofillHints: const <String>[
                                        AutofillHints.creditCardExpirationDay
                                      ],
                                      textInputAction: TextInputAction.next,
                                      onChanged: (value) {
                                        if (value.length == 2) {
                                          expiryDate = TextEditingController(
                                              text: '$value/');
                                          update();
                                        } else if (value.length == 4) {
                                          FocusScope.of(context).nextFocus();
                                        }
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '*';
                                        } else if (value.length != 5) {
                                          return '*';
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Expired Date
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'CVV',
                                        hintText: 'XXX',
                                      ),
                                      controller: cvvCode,
                                      keyboardType: TextInputType.number,
                                      autofillHints: const <String>[
                                        AutofillHints.creditCardSecurityCode
                                      ],
                                      textInputAction: TextInputAction.next,
                                      onChanged: (value) {
                                        if (value.length == 3) {
                                          FocusScope.of(context).nextFocus();
                                        }
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '*';
                                        } else if (value.length != 3) {
                                          return '*';
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Card Holder
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Card Holder'),
                              controller: cardHolderName,
                              keyboardType: TextInputType.name,
                              autofillHints: const <String>[
                                AutofillHints.creditCardName
                              ],
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '*';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // Button
                            ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {}
                              },
                              child: text(
                                  text:
                                      TextString(en: 'Continue', ar: 'استمر')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
