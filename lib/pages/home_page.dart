import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:french_vocabulary_trainer_app/pages/category_words_page.dart';
import 'package:french_vocabulary_trainer_app/pages/words_page.dart';

import 'category_list_page.dart';
import 'flashcard_practice_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> pages = [
    WordsPage(),
    CategoryWordsPage(),
    FlashcardPracticePage(),
    CategoryListPage(),
  ];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //
      //   },
      //   tooltip: 'Add new word',
      //   child: const Icon(Icons.add),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: [
          Icons.home,
          Icons.book_sharp,
          Icons.quiz,
          Icons.category_rounded,
        ],
        gapLocation: GapLocation.none,
        activeIndex: currentIndex,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) async {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
