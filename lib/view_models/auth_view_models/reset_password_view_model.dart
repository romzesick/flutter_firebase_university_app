import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/auth_service.dart';

/// Klasa opakowująca dane typu T.
/// Służy do jednorazowego odczytu wartości (np. wiadomości o błędach),
/// aby uniknąć wielokrotnego wyświetlania tego samego komunikatu.
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

/// Klasa reprezentująca stan widoku resetowania hasła.
/// Zawiera e-mail, flagę ładowania oraz komunikat (np. o błędzie lub sukcesie).
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

/// ViewModel odpowiedzialny za resetowanie hasła użytkownika.
///
/// Używany w `ForgotPasswordPage`. Zarządza:
/// - wprowadzonym e-mailem,
/// - walidacją,
/// - komunikacją z Firebase przez [AuthService],
/// - oraz zwracaniem komunikatów do UI.
class ResetPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  var _state = const _ResetPasswordViewModelState();

  /// Zwraca aktualny stan.
  _ResetPasswordViewModelState get state => _state;

  /// Getter do e-maila (oczyszczony z białych znaków).
  String get email => _state.email.trim();

  /// Flaga informująca, czy trwa ładowanie.
  bool get isLoading => _state.isLoading;

  /// Ostatni komunikat (błąd lub sukces).
  Event<String>? get message => _state.message;

  /// Czyta wpisywany e-mail
  void changeEmail(String value) {
    if (email == value) return;
    _state = _state.copyWith(email: value);
    notifyListeners();
  }

  /// Wysyła żądanie resetu hasła.
  ///
  /// Sprawdza poprawność e-maila, próbuje wysłać link,
  /// a następnie zwraca `true` lub `false` w zależności od rezultatu.
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

  /// Ustawia flagę ładowania i odświeża UI
  void _setLoading(bool value) {
    if (!hasListeners) return;
    _state = _state.copyWith(isLoading: value);
    notifyListeners();
  }

  /// Emituje nowy komunikat o błędzie do UI
  void _emitMessage(String message) {
    if (!hasListeners) return;
    _state = _state.copyWith(message: Event(message));
    notifyListeners();
  }
}
