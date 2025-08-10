import 'package:flutter/material.dart';
import 'package:french_vocabulary_trainer_app/pages/home_page.dart';
import 'package:french_vocabulary_trainer_app/provider/word_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WordProvider()..loadWords(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
