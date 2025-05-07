import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class Event<T> {
  final T _data;
  bool _hasBeenHandled = false;

  Event(this._data);

  T? get dataIfNotHandled {
    if (_hasBeenHandled) {
      return null;
    } else {
      _hasBeenHandled = true;
      return _data;
    }
  }

  T get peekData => _data; // если нужно получить без обработки
}

class _SignupViewModelState {
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final String age;
  final bool isLoading;
  final Event<String>? errorMessage;

  const _SignupViewModelState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.name = '',
    this.age = '',
    this.isLoading = false,
    this.errorMessage,
  });

  _SignupViewModelState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? name,
    String? age,
    bool? isLoading,
    Event<String>? errorMessage,
  }) {
    return _SignupViewModelState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      name: name ?? this.name,
      age: age ?? this.age,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SignUpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  var _state = const _SignupViewModelState();
  _SignupViewModelState get state => _state;

  String get email => _state.email.trim();
  String get password => _state.password.trim();
  String get confirmPassword => _state.confirmPassword.trim();
  String get name => _state.name.trim();
  String get age => _state.age.trim();
  bool get isLoading => _state.isLoading;

  void changeEmail(String value) {
    if (email == value) return;
    _state = _state.copyWith(email: value);
    notifyListeners();
  }

  void changePassword(String value) {
    if (password == value) return;
    _state = _state.copyWith(password: value);
    notifyListeners();
  }

  void changeConfirmPassword(String value) {
    if (confirmPassword == value) return;
    _state = _state.copyWith(confirmPassword: value);
    notifyListeners();
  }

  void changeName(String value) {
    if (name == value) return;
    _state = _state.copyWith(name: value);
    notifyListeners();
  }

  void changeAge(String value) {
    if (age == value) return;
    _state = _state.copyWith(age: value);
    notifyListeners();
  }

  Future<bool> onSignUpButtonPressed() async {
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        name.isEmpty ||
        age.isEmpty) {
      _emitErrorMessage('The fields are empty');
      return false;
    }

    if (password != confirmPassword) {
      _emitErrorMessage('Passwords do not match');
      return false;
    }

    _setLoading(true);

    try {
      await _authService.signUp(email, password, name, int.parse(age));
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _emitErrorMessage('User with this email already exists');
      } else if (e.code == 'weak-password') {
        _emitErrorMessage('Weak password');
      } else {
        _emitErrorMessage('Auth error: ${e.message}');
      }
    } catch (e) {
      _emitErrorMessage('Unexpected error: $e');
    }

    _setLoading(false);
    return false;
  }

  void _setLoading(bool isLoading) {
    if (!hasListeners) return;
    _state = _state.copyWith(isLoading: isLoading);
    notifyListeners();
  }

  void _emitErrorMessage(String message) {
    if (!hasListeners) return;
    _state = _state.copyWith(errorMessage: Event(message));
    notifyListeners();
  }
}
