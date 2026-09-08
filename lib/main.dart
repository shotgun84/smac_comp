import 'package:flutter/material.dart';
import 'app.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Familia — Eat together, decide together',
      debugShowCheckedModeBanner: false,
      theme: familiaTheme(),
      home: const FamiliaRoot(),
    );
  }
}
