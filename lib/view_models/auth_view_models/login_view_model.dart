// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/auth_service.dart';

/// Klasa opakowująca dane, które powinny być użyte tylko raz (np. komunikaty o błędach)
class Event<T> {
  final T _data;
  bool _hasBeenHandled = false;

  Event(this._data);

  /// Zwraca dane tylko jeśli nie były jeszcze obsłużone
  T? get dataIfNotHandled {
    if (_hasBeenHandled) {
      return null;
    } else {
      _hasBeenHandled = true;
      return _data;
    }
  }

  /// Zwraca dane niezależnie od stanu użycia
  T get peekData => _data;
}

/// Klasa reprezentująca stan logowania
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

  /// Tworzy kopię obecnego stanu z możliwością nadpisania wybranych pól
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

/// ViewModel odpowiedzialny za logikę logowania
class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  var _state = const _LoginViewModelState();
  _LoginViewModelState get state => _state;

  // Gettery skracające dostęp do danych
  String get login => _state.login.trim();
  String get password => _state.password.trim();
  bool get isLoading => _state.isLoading;

  /// Aktualizuje pole loginu
  void changeLogin(String value) {
    if (login == value) return;
    _state = _state.copyWith(login: value);
    notifyListeners();
  }

  /// Aktualizuje pole hasła
  void changePassword(String value) {
    if (password == value) return;
    _state = _state.copyWith(password: value);
    notifyListeners();
  }

  /// Metoda wywoływana po naciśnięciu przycisku logowania
  Future<void> onSignInButtonPressed() async {
    if (login.isEmpty || password.isEmpty) {
      _emitErrorMessage('The fields are empty');
      return;
    }

    _setLoading(true);

    try {
      // Próba logowania
      await _authService.signIn(login, password);
      _setLoading(false);
    } on FirebaseAuthException catch (e) {
      // Obsługa błędów Firebase
      if (e.code == 'user-not-found') {
        _emitErrorMessage('User not found with this email.');
      } else if (e.code == 'wrong-password') {
        _emitErrorMessage('Incorrect password.');
      } else {
        _emitErrorMessage('Auth error: ${e.message}');
      }
    } catch (e) {
      // Obsługa nieoczekiwanych błędów
      _emitErrorMessage('Unexpected error: $e');
    }

    _setLoading(false);
  }

  /// Ustawia stan ładowania
  void _setLoading(bool isLoading) {
    if (!hasListeners) return;
    _state = _state.copyWith(isLoading: isLoading);
    notifyListeners();
  }

  /// Emituje komunikat o błędzie
  void _emitErrorMessage(String message) {
    if (!hasListeners) return;
    _state = _state.copyWith(errorMessage: Event(message));
    notifyListeners();
  }
}
