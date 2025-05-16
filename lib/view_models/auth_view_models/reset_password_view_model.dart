import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/auth_service.dart';

/// Klasa opakowująca dane jednorazowe (np. komunikaty)
class Event<T> {
  final T _data;
  bool _hasBeenHandled = false;

  Event(this._data);

  /// Zwraca dane tylko jeśli nie były wcześniej obsłużone
  T? get dataIfNotHandled {
    if (_hasBeenHandled) {
      return null;
    } else {
      _hasBeenHandled = true;
      return _data;
    }
  }

  /// Zwraca dane bez oznaczenia jako obsłużone
  T get peekData => _data;
}

/// Reprezentuje aktualny stan widoku resetowania hasła
class _ResetPasswordViewModelState {
  final String email;
  final bool isLoading;
  final Event<String>? message;

  const _ResetPasswordViewModelState({
    this.email = '',
    this.isLoading = false,
    this.message,
  });

  /// Tworzy nową wersję stanu z możliwością zmiany wybranych pól
  _ResetPasswordViewModelState copyWith({
    String? email,
    bool? isLoading,
    Event<String>? message,
  }) {
    return _ResetPasswordViewModelState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
    );
  }
}

/// ViewModel odpowiedzialny za logikę resetowania hasła
class ResetPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  var _state = const _ResetPasswordViewModelState();
  _ResetPasswordViewModelState get state => _state;

  // Skrócone gettery do danych stanu
  String get email => _state.email.trim();
  bool get isLoading => _state.isLoading;
  Event<String>? get message => _state.message;

  /// Zmienia wpisany adres e-mail
  void changeEmail(String value) {
    if (email == value) return;
    _state = _state.copyWith(email: value);
    notifyListeners();
  }

  /// Wysyła żądanie resetu hasła
  Future<bool> resetPassword() async {
    if (email.isEmpty) {
      _emitMessage('The field is empty');
      return false;
    }

    _setLoading(true);
    try {
      // Wysyłanie linku resetującego
      await _authService.resetPassword(email);
      _emitMessage('The link has been sent to your email');
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      // Obsługa typowych błędów Firebase
      if (e.code == 'user-not-found') {
        _emitMessage('No user found with this email');
      } else if (e.code == 'invalid-email') {
        _emitMessage('Invalid email format');
      } else {
        _emitMessage('Auth error: ${e.message}');
      }
    } catch (e) {
      // Obsługa innych wyjątków
      _emitMessage('Unexpected error: $e');
    }
    _setLoading(false);
    return false;
  }

  /// Aktualizuje stan ładowania
  void _setLoading(bool value) {
    if (!hasListeners) return;
    _state = _state.copyWith(isLoading: value);
    notifyListeners();
  }

  /// Wysyła komunikat (np. sukces lub błąd)
  void _emitMessage(String message) {
    if (!hasListeners) return;
    _state = _state.copyWith(message: Event(message));
    notifyListeners();
  }
}
