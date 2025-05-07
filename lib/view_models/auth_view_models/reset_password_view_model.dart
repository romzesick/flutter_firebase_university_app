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

  T get peekData => _data; // если нужно без пометки как обработанное
}

class _ResetPasswordViewModelState {
  final String email;
  final bool isLoading;
  final Event<String>? message;

  const _ResetPasswordViewModelState({
    this.email = '',
    this.isLoading = false,
    this.message,
  });

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

class ResetPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  var _state = const _ResetPasswordViewModelState();
  _ResetPasswordViewModelState get state => _state;

  String get email => _state.email.trim();
  bool get isLoading => _state.isLoading;
  Event<String>? get message => _state.message;

  void changeEmail(String value) {
    if (email == value) return;
    _state = _state.copyWith(email: value);
    notifyListeners();
  }

  Future<bool> resetPassword() async {
    if (email.isEmpty) {
      _emitMessage('The field is empty');
      return false;
    }

    _setLoading(true);
    try {
      await _authService.resetPassword(email);
      _emitMessage('The link has been sent to your email');
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _emitMessage('No user found with this email');
      } else if (e.code == 'invalid-email') {
        _emitMessage('Invalid email format');
      } else {
        _emitMessage('Auth error: ${e.message}');
      }
    } catch (e) {
      _emitMessage('Unexpected error: $e');
    }
    _setLoading(false);
    return false;
  }

  void _setLoading(bool value) {
    if (!hasListeners) return;
    _state = _state.copyWith(isLoading: value);
    notifyListeners();
  }

  void _emitMessage(String message) {
    if (!hasListeners) return;
    _state = _state.copyWith(message: Event(message));
    notifyListeners();
  }
}
