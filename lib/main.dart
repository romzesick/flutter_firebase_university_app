import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_flutter_app/ui/widgets/my_app.dart';
import 'package:firebase_flutter_app/view_models/goals_view_models/goals_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalsViewModel()),
        // другие ViewModel'ы, если есть
      ],
      child: const MyApp(),
    ),
  );
}
