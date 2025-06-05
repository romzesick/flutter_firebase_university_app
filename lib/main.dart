import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_flutter_app/ui/widgets/my_app.dart';
import 'package:firebase_flutter_app/view_models/goals_view_models/goals_view_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Główna funkcja uruchamiająca aplikację.
///
/// Inicjalizuje Firebase, rejestruje obsługę powiadomień,
/// a następnie uruchamia aplikację Flutter z odpowiednimi Providerami.
void main() async {
  // Inicjalizacja Fluttera przed użyciem Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Firebase
  await Firebase.initializeApp();

  // Obsługa wiadomości push w tle
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Pobranie tokenu FCM urządzenia
  final messaging = FirebaseMessaging.instance;
  final token = await messaging.getToken();
  log('FCM Token: $token');

  // Żądanie uprawnień do wysyłania powiadomień
  final settings = await messaging.requestPermission();
  log('Permissions: ${settings.authorizationStatus}');

  // Foreground listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('Foreground: ${message.notification?.title}');
  });

  // Uruchomienie aplikacji z dostarczonym modelem GoalsViewModel
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GoalsViewModel())],
      child: const MyApp(),
    ),
  );
}

/// Funkcja obsługująca powiadomienia push, gdy aplikacja jest w tle lub zamknięta.
///
/// Firebase wymaga osobnej obsługi dla wiadomości w tle w osobnym izolacie.
/// Użycie adnotacji `@pragma('vm:entry-point')` zapobiega usunięciu tej funkcji podczas kompilacji.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('📩 Background: ${message.notification?.title}');
}
