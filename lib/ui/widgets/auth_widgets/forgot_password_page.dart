import 'package:firebase_flutter_app/ui/components/my_textfield.dart';
import 'package:firebase_flutter_app/view_models/auth_view_models/reset_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewModel(),
      child: const ForgotPasswordPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Reset Password'),
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.grey[300],
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, size: 100, color: Colors.grey[900]),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      'Write your email and we will send you a password reset link',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 20),

                  const _ResetTextField(),

                  SizedBox(height: 20),

                  const _ResetButton(),
                ],
              ),
            ),
          ),
        ),
        _ErrorHandler(),
      ],
    );
  }
}

class _ResetTextField extends StatelessWidget {
  const _ResetTextField();

  @override
  Widget build(BuildContext context) {
    return MyTextField(
      hintText: 'Email',
      obscureText: false,
      onChanged: context.read<ResetPasswordViewModel>().changeEmail,
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton();

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (ResetPasswordViewModel model) => model.isLoading,
    );

    if (isLoading) {
      return const CircularProgressIndicator();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
          final success =
              await context.read<ResetPasswordViewModel>().resetPassword();
          if (success && context.mounted) {
            Navigator.pop(context);
          }
        },

        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorHandler extends StatelessWidget {
  const _ErrorHandler();

  @override
  Widget build(BuildContext context) {
    return Consumer<ResetPasswordViewModel>(
      builder: (_, model, __) {
        final message = model.message?.dataIfNotHandled;
        if (message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              message.contains('has been sent ')
                  ? SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.green,
                  )
                  : SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.red,
                  ),
            );
          });
        }
        return const SizedBox.shrink();
      },
    );
  }
}
