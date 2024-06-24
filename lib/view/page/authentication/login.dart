import '/exports.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool loading = false;
  GlobalKey<FormState> formState = GlobalKey();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool obscureText = true;

  @override
  Widget build(BuildContext context) => AuthenticationForm(
        title: TextString(
          en: 'Login',
          ar: 'تسجيل الدخول',
        ),
        subTitle: TextString(
          en: 'Enter your email and password to continue',
          ar: 'ادخل بريدك الالكتروني وكلمة المرور',
        ),
        child: Form(
          key: formState,
          child: Column(
            children: [
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

              // Forget Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const ResetPasswordForm(),
                  ),
                  child: text(
                    text: TextString(
                      en: 'Forget Password',
                      ar: 'نسيت كلمة السر',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
              ),

              // Sign In
              ElevatedButton(
                onPressed: () => validate(),
                style: ElevatedButton.styleFrom(fixedSize: const Size(250, 50)),
                child: text(
                  text: TextString(en: 'Sign In', ar: 'تسجيل'),
                ),
              ),
            ],
          ),
        ),
      );

  void validate() {
    if (formState.currentState!.validate()) {
      try {
        FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text,
          password: password.text,
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
        ));
      }
    }
  }
}
