import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/services/auth_service.dart';
import 'package:flutter/material.dart';

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

/// Reprezentuje stan ViewModelu rejestracji.
/// Przechowuje dane wejściowe oraz flagi stanu.
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

  /// Tworzy kopię obecnego stanu z możliwością nadpisania wybranych pól
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

/// ViewModel obsługujący logikę rejestracji nowego użytkownika.
/// Komunikuje się z [AuthService], obsługuje błędy i aktualizuje UI.
class SignUpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  /// Aktualny stan formularza
  var _state = const _SignupViewModelState();
  _SignupViewModelState get state => _state;

  /// Gettery upraszczające dostęp do stanu
  String get email => _state.email.trim();
  String get password => _state.password.trim();
  String get confirmPassword => _state.confirmPassword.trim();
  String get name => _state.name.trim();
  String get age => _state.age.trim();
  bool get isLoading => _state.isLoading;

  /// Aktualizuje pole e-maila
  void changeEmail(String value) {
    if (email == value) return;
    _state = _state.copyWith(email: value);
    notifyListeners();
  }

  /// Aktualizuje pole hasła
  void changePassword(String value) {
    if (password == value) return;
    _state = _state.copyWith(password: value);
    notifyListeners();
  }

  /// Aktualizuje pole potwierdzenia hasła
  void changeConfirmPassword(String value) {
    if (confirmPassword == value) return;
    _state = _state.copyWith(confirmPassword: value);
    notifyListeners();
  }

  /// Aktualizuje pole imienia
  void changeName(String value) {
    if (name == value) return;
    _state = _state.copyWith(name: value);
    notifyListeners();
  }

  /// Aktualizuje pole wieku
  void changeAge(String value) {
    if (age == value) return;
    _state = _state.copyWith(age: value);
    notifyListeners();
  }

  /// Obsługuje naciśnięcie przycisku "Sign Up"
  /// Waliduje dane i przekazuje je do [AuthService]
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
      // Próba rejestracji użytkownika
      await _authService.signUp(email, password, name, int.parse(age));
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      // Obsługa błędów Firebase
      if (e.code == 'email-already-in-use') {
        _emitErrorMessage('User with this email already exists');
      } else if (e.code == 'weak-password') {
        _emitErrorMessage('Weak password');
      } else {
        _emitErrorMessage('Auth error: ${e.message}');
      }
    } catch (e) {
      // Obsługa nieoczekiwanych błędów
      _emitErrorMessage('Unexpected error: $e');
    }

    _setLoading(false);
    return false;
  }

  /// Ustawia flagę ładowania i odświeża UI
  void _setLoading(bool isLoading) {
    if (!hasListeners) return;
    _state = _state.copyWith(isLoading: isLoading);
    notifyListeners();
  }

  /// Emituje nowy komunikat o błędzie do UI
  void _emitErrorMessage(String message) {
    if (!hasListeners) return;
    _state = _state.copyWith(errorMessage: Event(message));
    notifyListeners();
  }
}
