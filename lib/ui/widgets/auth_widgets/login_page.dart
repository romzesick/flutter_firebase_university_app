import 'package:firebase_flutter_app/ui/widgets/auth_widgets/forgot_password_page.dart';
import 'package:firebase_flutter_app/ui/widgets/auth_widgets/signup_page.dart';
import 'package:firebase_flutter_app/view_models/auth_view_models/login_view_model.dart';
import 'package:flutter/material.dart';

import 'package:firebase_flutter_app/ui/components/my_square_tile.dart';
import 'package:provider/provider.dart';

import '../../components/my_login_button.dart';
import '../../components/my_textfield.dart';

/// Ekran logowania – formularz logowania, przyciski i obsługa błędów
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  /// Metoda fabryczna do stworzenia strony z odpowiednim ViewModel
  static Widget create() {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),

                    // Ikona logowania
                    Icon(Icons.login, size: 100, color: Colors.green),
                    const SizedBox(height: 50),

                    // Powitanie użytkownika
                    Text(
                      'Welcome back you\'ve been missed!',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 25),

                    // Pole email
                    _EmailField(),
                    const SizedBox(height: 10),

                    // Pole hasło
                    _PasswordField(),
                    const SizedBox(height: 10),

                    // Przycisk: Zapomniałem hasła
                    _ForgotPasswordButton(),
                    const SizedBox(height: 25),

                    // Przycisk logowania
                    const LoginButton(),
                    const SizedBox(height: 10),

                    // Przycisk rejestracji
                    _RegisterNow(),
                    const SizedBox(height: 35),

                    // Linia podziału
                    _OrContinueDivider(),
                    const SizedBox(height: 50),

                    // Logowanie przez Google/Apple
                    const _SocialLoginRow(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Wyświetlanie błędów logowania
        _ErrorHandler(),
      ],
    );
  }
}

/// Pole tekstowe do wpisania e-maila
class _EmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyTextField(
      hintText: 'Email',
      obscureText: false,
      onChanged: context.read<LoginViewModel>().changeLogin,
    );
  }
}

/// Pole tekstowe do wpisania hasła
class _PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyTextField(
      hintText: 'Password',
      obscureText: true,
      onChanged: context.read<LoginViewModel>().changePassword,
    );
  }
}

/// Przycisk do przejścia na stronę odzyskiwania hasła
class _ForgotPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ForgotPasswordPage.create()),
            ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Przycisk logowania – pokazuje spinner podczas ładowania
class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((LoginViewModel model) => model.isLoading);

    if (isLoading) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    return MyButton(
      signInUp: 'Sign In',
      onTap: () async {
        // Ukrycie klawiatury
        FocusScope.of(context).unfocus();
        await context.read<LoginViewModel>().onSignInButtonPressed();
      },
    );
  }
}

/// Sekcja z przyciskiem „Zarejestruj się”
class _RegisterNow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          const Text(
            'Don\'t have an account?',
            style: TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupPage.create()),
                ),
            child: Text('Register Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Separator z tekstem „Lub kontynuuj przez”
class _OrContinueDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 0.5, color: Colors.white)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'Or continue with',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const Expanded(child: Divider(thickness: 0.5, color: Colors.white)),
      ],
    );
  }
}

/// Rząd przycisków logowania społecznościowego (Google i Apple)
class _SocialLoginRow extends StatelessWidget {
  const _SocialLoginRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SquareTile(imagePath: 'images/google.png'),
        SizedBox(width: 25),
        SquareTile(imagePath: 'images/apple.png'),
      ],
    );
  }
}

/// Komponent odpowiedzialny za wyświetlanie błędów logowania
class _ErrorHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (_, model, __) {
        final message = model.state.errorMessage?.dataIfNotHandled;
        if (message != null) {
          // Pokazanie SnackBar z błędem
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          });
        }
        return const SizedBox.shrink();
      },
    );
  }
}
