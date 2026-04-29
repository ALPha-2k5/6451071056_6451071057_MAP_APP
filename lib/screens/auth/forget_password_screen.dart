import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../common/widgets/primary_button.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  Future<void> _submit(BuildContext context) async {
    final bool isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.resetEmailSent,
          arguments: emailController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      final String message;
      if (e.code == 'user-not-found') {
        message = 'Email khong ton tai';
      } else if (e.code == 'invalid-email') {
        message = 'Email khong hop le';
      } else if (e.code == 'too-many-requests') {
        message = 'Thu lai sau';
      } else {
        message = 'Gui email that bai';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khôi phục mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return Validators.validateEmail(value ?? '');
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                title: 'Gửi yêu cầu',
                onPressed: () => _submit(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}