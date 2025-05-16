import 'package:firebase_flutter_app/ui/components/my_textfield.dart';
import 'package:firebase_flutter_app/view_models/auth_view_models/reset_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Strona do resetowania hasła – użytkownik podaje email, aby otrzymać link
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  /// Tworzy stronę z powiązanym modelem ResetPasswordViewModel
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
                  // Ikona wiadomości e-mail
                  Icon(Icons.email, size: 100, color: Colors.grey[900]),
                  const SizedBox(height: 50),

                  // Instrukcja dla użytkownika
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      'Write your email and we will send you a password reset link',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Pole do wpisania e-maila
                  const _ResetTextField(),

                  SizedBox(height: 20),

                  // Przycisk do zresetowania hasła
                  const _ResetButton(),
                ],
              ),
            ),
          ),
        ),

        // Obsługa komunikatów o błędach i sukcesie
        _ErrorHandler(),
      ],
    );
  }
}

/// Pole tekstowe do wpisania adresu e-mail
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

/// Przycisk wysyłający żądanie resetu hasła
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
          // Ukrycie klawiatury
          FocusScope.of(context).unfocus();

          // Próba resetu hasła
          final success =
              await context.read<ResetPasswordViewModel>().resetPassword();

          // Powrót na poprzednią stronę po sukcesie
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

/// Obsługuje wyświetlanie błędów i komunikatów o sukcesie
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
