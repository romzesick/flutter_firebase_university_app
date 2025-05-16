import 'package:firebase_flutter_app/ui/widgets/auth_widgets/auth_wrapper_widget.dart';
import 'package:firebase_flutter_app/view_models/auth_view_models/signup_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/my_login_button.dart';
import '../../components/my_textfield.dart';

/// Strona rejestracji – tworzenie nowego konta użytkownika
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  /// Tworzy stronę z odpowiednim modelem widoku (ViewModel)
  static Widget create() {
    return ChangeNotifierProvider(
      create: (context) => SignUpViewModel(),
      child: SignupPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[300],
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),

                    // Ikona i nagłówek
                    Icon(Icons.lock, size: 100, color: Colors.grey[900]),
                    const SizedBox(height: 50),
                    Text(
                      'Create your account!',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                    const SizedBox(height: 25),

                    // Pola formularza
                    _NameField(),
                    const SizedBox(height: 10),

                    _AgeField(),
                    const SizedBox(height: 10),

                    _EmailField(),
                    const SizedBox(height: 10),

                    _PasswordField(),
                    const SizedBox(height: 10),

                    _ConfirmPasswordField(),
                    const SizedBox(height: 25),

                    // Przycisk rejestracji
                    const SignupButton(),
                    const SizedBox(height: 10),

                    // Przejście do logowania
                    _LoginInstead(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Obsługa błędów
        _ErrorHandler(),
      ],
    );
  }
}

/// Pole do wpisania imienia
class _NameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyTextField(
      hintText: 'Name',
      obscureText: false,
      onChanged: context.read<SignUpViewModel>().changeName,
    );
  }
}

/// Pole do wpisania wieku
class _AgeField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyTextField(
      hintText: 'Age',
      obscureText: false,
      onChanged: context.read<SignUpViewModel>().changeAge,
    );
  }
}

/// Pole do wpisania adresu e-mail
class _EmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyTextField(
      hintText: 'Email',
      obscureText: false,
      onChanged: context.read<SignUpViewModel>().changeEmail,
    );
  }
}

/// Pole do wpisania hasła
class _PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyTextField(
      hintText: 'Password',
      obscureText: true,
      onChanged: context.read<SignUpViewModel>().changePassword,
    );
  }
}

/// Pole do potwierdzenia hasła
class _ConfirmPasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyTextField(
      hintText: 'Confirm Password',
      obscureText: true,
      onChanged: context.read<SignUpViewModel>().changeConfirmPassword,
    );
  }
}

/// Przycisk tworzenia konta
class SignupButton extends StatelessWidget {
  const SignupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (SignUpViewModel model) => model.isLoading,
    );

    if (isLoading) {
      return const CircularProgressIndicator();
    }

    return MyButton(
      signInUp: 'Sign Up',
      onTap: () async {
        // Ukrycie klawiatury
        FocusScope.of(context).unfocus();

        // Próba rejestracji
        final success =
            await context.read<SignUpViewModel>().onSignUpButtonPressed();

        // Jeśli sukces — przejście do głównego wrappera (AuthWrapper)
        if (success && context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthWrapperWidget()),
            (route) => false,
          );
        }
      },
    );
  }
}

/// Przycisk przejścia do strony logowania
class _LoginInstead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account?'),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Log in now',
              style: TextStyle(color: Colors.grey[900]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wyświetla komunikaty o błędach (np. niepoprawne dane)
class _ErrorHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpViewModel>(
      builder: (_, model, __) {
        final message = model.state.errorMessage?.dataIfNotHandled;
        if (message != null) {
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
