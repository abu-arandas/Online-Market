import '/exports.dart';

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  @override
  Widget build(BuildContext context) => AlertDialog(
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
        actions: [
          OutlinedButton(
            onPressed: () {},
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Confirm'),
          ),
        ],
      );
}
