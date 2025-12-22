import 'package:flutter/material.dart';
import 'package:agrikeep/app.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:agrikeep/pages/providers/auth_provider.dart';
import 'package:agrikeep/pages/providers/farm_provider.dart';
import 'package:agrikeep/pages/providers/crop_provider.dart';
import 'firebase_options.dart'; // Only import once

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ ✅ ✅ ✅ ✅ Firebase initialized");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
      ],
      child: const AgriKeepApp(),
    ),
  );
}

class AgriKeepApp extends StatelessWidget {
  const AgriKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriKeep - Seed 2 Harvest',
      theme: AgriKeepTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const App(), // This is your App() widget from app.dart
    );
  }
}