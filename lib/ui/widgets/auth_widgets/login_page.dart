import 'package:firebase_flutter_app/ui/widgets/auth_widgets/forgot_password_page.dart';
import 'package:firebase_flutter_app/ui/widgets/auth_widgets/signup_page.dart';
import 'package:firebase_flutter_app/view_models/auth_view_models/login_view_model.dart';
import 'package:flutter/material.dart';

import 'package:firebase_flutter_app/ui/components/my_square_tile.dart';
import 'package:provider/provider.dart';

import '../../components/my_login_button.dart';
import '../../components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
          backgroundColor: Colors.grey[300],
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Icon(Icons.login, size: 100, color: Colors.grey[900]),
                    const SizedBox(height: 50),
                    Text(
                      'Welcome back you\'ve been missed!',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                    const SizedBox(height: 25),

                    _EmailField(),

                    const SizedBox(height: 10),

                    _PasswordField(),

                    const SizedBox(height: 10),

                    _ForgotPasswordButton(),

                    const SizedBox(height: 25),

                    // sign in button
                    const LoginButton(),

                    const SizedBox(height: 10),

                    _RegisterNow(),

                    const SizedBox(height: 35),

                    _OrContinueDivider(),

                    const SizedBox(height: 50),

                    const _SocialLoginRow(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Секция для обработки ошибок
        _ErrorHandler(),
      ],
    );
  }
}

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
            style: TextStyle(color: Colors.grey[950]),
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((LoginViewModel model) => model.isLoading);

    if (isLoading) {
      return const CircularProgressIndicator();
    }
    return MyButton(
      signInUp: 'Sign In',
      onTap: () async {
        FocusScope.of(context).unfocus();
        await context.read<LoginViewModel>().onSignInButtonPressed();
      },
    );
  }
}

class _RegisterNow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          const Text('Don\'t have an account?'),
          TextButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupPage.create()),
                ),
            child: Text(
              'Register Now',
              style: TextStyle(color: Colors.grey[900]),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrContinueDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'Or continue with',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        const Expanded(child: Divider(thickness: 0.5)),
      ],
    );
  }
}

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

class _ErrorHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
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
