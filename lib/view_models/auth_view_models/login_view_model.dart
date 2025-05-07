// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_flutter_app/services/auth_service.dart';

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

class _LoginViewModelState {
  final String login;
  final String password;
  final bool isLoading;
  final Event<String>? errorMessage;

  const _LoginViewModelState({
    this.login = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
  });

  _LoginViewModelState copyWith({
    String? login,
    String? password,
    bool? isLoading,
    Event<String>? errorMessage,
  }) {
    return _LoginViewModelState(
      login: login ?? this.login,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  var _state = const _LoginViewModelState();
  _LoginViewModelState get state => _state;

  String get login => _state.login.trim();
  String get password => _state.password.trim();
  bool get isLoading => _state.isLoading;

  void changeLogin(String value) {
    if (login == value) return;
    _state = _state.copyWith(login: value);
    notifyListeners();
  }

  void changePassword(String value) {
    if (password == value) return;
    _state = _state.copyWith(password: value);
    notifyListeners();
  }

  Future<void> onSignInButtonPressed() async {
    if (login.isEmpty || password.isEmpty) {
      _emitErrorMessage('The fields are empty');
      return;
    }

    _setLoading(true);

    try {
      await _authService.signIn(login, password);
      _setLoading(false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _emitErrorMessage('User not found with this email.');
      } else if (e.code == 'wrong-password') {
        _emitErrorMessage('Incorrect password.');
      } else {
        _emitErrorMessage('Auth error: ${e.message}');
      }
    } catch (e) {
      _emitErrorMessage('Unexpected error: $e');
    }

    _setLoading(false);
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
