import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_flutter_app/ui/widgets/my_app.dart';
import 'package:firebase_flutter_app/view_models/goals_view_models/goals_view_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;
  final token = await messaging.getToken();
  log('🔥 FCM Token: $token');

  // Запрос разрешений
  final settings = await messaging.requestPermission();
  log('🔐 Permissions: ${settings.authorizationStatus}');

  // Foreground listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('🔔 Foreground: ${message.notification?.title}');
  });

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GoalsViewModel())],
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('📩 Background: ${message.notification?.title}');
}
