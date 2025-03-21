import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weed Detection App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SignInScreen(), // Start with the Sign-In Screen
    );
  }
}