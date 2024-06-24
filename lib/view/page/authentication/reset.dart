import '/exports.dart';

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  GlobalKey<FormState> formState = GlobalKey();

  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: ListTile(
          title: text(
            text: TextString(
              en: 'Reset Password',
              ar: 'اعادة تعيين كلمة المرور',
            ),
          ),
          subtitle: text(
            text: TextString(
              en: 'Enter your email address',
              ar: 'ادخل عنوان بريدك الالكتروني',
            ),
          ),
        ),
        contentPadding: const EdgeInsets.all(8),
        content: Form(
          child: TextFormField(
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
            onFieldSubmitted: (value) => validate(),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => validate(),
            child: const Text('Confirm'),
          ),
        ],
      );

  void validate() {
    if (formState.currentState!.validate()) {
      try {
        FirebaseAuth.instance.sendPasswordResetEmail(
          email: email.text,
        );

        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
        ));
      }
    }
  }
}
