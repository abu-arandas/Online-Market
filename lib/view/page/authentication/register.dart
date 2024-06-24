import '/exports.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool loading = false;
  GlobalKey<FormState> formState = GlobalKey();

  TextEditingController givenName = TextEditingController();
  TextEditingController familyName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  PhoneController phone = PhoneController(
    initialValue: const PhoneNumber(isoCode: IsoCode.JO, nsn: ''),
  );

  bool obscureText = true;

  @override
  Widget build(BuildContext context) => AuthenticationForm(
        title: TextString(en: 'Register', ar: 'تسجيل'),
        subTitle: TextString(
          en: 'Enter your details to register',
          ar: 'أدخل بياناتك للتسجيل',
        ),
        child: Form(
          key: formState,
          child: Column(
            children: [
              // Name
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      autofillHints: const [AutofillHints.givenName],
                      controller: givenName,
                      decoration: InputDecoration(
                        labelText: textString(
                          TextString(en: 'First Name', ar: 'الاسم الاول'),
                        ),
                      ),
                      enableSuggestions: true,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          'empty';
                        } else {
                          null;
                        }
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'empty';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      autofillHints: const [AutofillHints.familyName],
                      controller: familyName,
                      decoration: InputDecoration(
                        labelText: textString(
                          TextString(en: 'Last Name', ar: 'الاسم الخير'),
                        ),
                      ),
                      enableSuggestions: true,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                autofillHints: const [AutofillHints.email],
                controller: email,
                decoration: InputDecoration(
                  labelText: textString(
                    TextString(
                      en: 'Email',
                      ar: 'البريد الالكتروني',
                    ),
                  ),
                ),
                enableSuggestions: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  if (value.isEmpty) {
                    'empty';
                  } else if (!value.isEmail) {
                    'not valid email';
                  } else {
                    null;
                  }
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'empty';
                  } else if (!value.isEmail) {
                    return 'not valid email';
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Phone
              PhoneFormField(
                autofillHints: const [AutofillHints.telephoneNumber],
                enableSuggestions: true,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                controller: phone,
                decoration: InputDecoration(
                  labelText: textString(
                    TextString(en: 'Phone', ar: 'رقم الهاتف'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                autofillHints: const [AutofillHints.password],
                controller: password,
                decoration: InputDecoration(
                  labelText: textString(
                    TextString(en: 'Password', ar: 'كلمة السر'),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscureText = !obscureText),
                    icon: Icon(obscureText ? Icons.remove_red_eye : Icons.lock),
                  ),
                ),
                enableSuggestions: true,
                keyboardType: TextInputType.visiblePassword,
                obscureText: obscureText,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) => validate(),
                onChanged: (value) {
                  if (value.isEmpty) {
                    'empty';
                  } else if (value.length < 6) {
                    'less than 6 characters';
                  } else {
                    null;
                  }
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'empty';
                  } else if (value.length < 6) {
                    return 'less than 6 characters';
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Sign Up
              ElevatedButton(
                onPressed: () => validate(),
                style: ElevatedButton.styleFrom(fixedSize: const Size(250, 50)),
                child: text(text: TextString(en: 'Sign Up', ar: 'تسجيل')),
              ),
            ],
          ),
        ),
      );

  void validate() {
    if (formState.currentState!.validate()) {
      try {
        FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email.text,
              password: password.text,
            )
            .then((value) => FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set(UserModel(
                  id: FirebaseAuth.instance.currentUser!.uid,
                  name: '${givenName.text} ${familyName.text}',
                  email: email.text,
                  image:
                      'https://firebasestorage.googleapis.com/v0/b/alkhatib-market.appspot.com/o/no-profile-picture-icon.webp?alt=media&token=bfac8dae-344d-4cc9-b763-421a5c0d8988',
                  phone: phone.value,
                  promoCodes: [PromoCodeModel(id: 'new', discont: 0.25)],
                ).toJson()));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
        ));
      }
    }
  }
}
