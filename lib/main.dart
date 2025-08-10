import 'package:flutter/material.dart';
import 'package:french_vocabulary_trainer_app/pages/home_page.dart';
import 'package:french_vocabulary_trainer_app/providers/provider_category.dart';
import 'package:french_vocabulary_trainer_app/providers/word_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WordProvider()..loadWords()),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),
      ],
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
