import 'package:flutter/material.dart';

import '../core/database_helper.dart';
import '../models/model_vocab_word.dart';

class FlashcardPracticePage extends StatefulWidget {
  const FlashcardPracticePage({super.key});

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage>
    with SingleTickerProviderStateMixin {
  final db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _categories = [];
  List<VocabWord> _words = [];
  int _selectedCategoryId = -1; // -1 = All
  int _currentIndex = 0;
  bool _showMeaning = false;

  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats =
        (await db.getCategories())
            .map((cat) => {'id': cat.id, 'name': cat.name})
            .toList();
    setState(() {
      _categories = [
        {'id': -2, 'name': 'Learned'},
        {'id': -1, 'name': 'All'},
        ...cats,
      ];
    });
    _loadWords();
  }

  Future<void> _loadWords() async {
    List<VocabWord> allWords;

    if (_selectedCategoryId == -2) {
      allWords = await db.getWordsByCategoryAndLearned();
    } else if (_selectedCategoryId == -1) {
      allWords = await db.getAllWords();
    } else {
      allWords = await db.getWordsByCategoryAndLearning(_selectedCategoryId);
    }

    setState(() {
      _words = allWords;
      _currentIndex = 0;
      _showMeaning = false;
    });
  }

  void _nextCard() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _showMeaning = false;
        _controller.reset();
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showMeaning = false;
        _controller.reset();
      });
    }
  }

  void _flipCard() {
    if (_showMeaning) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _showMeaning = !_showMeaning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Practice'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Selector
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategoryId == cat['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = cat['id'];
                    });
                    _loadWords();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        cat['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // const SizedBox(height: 10),
          Text(
            '${_currentIndex + 1} / ${_words.length}', // counter
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          // Flashcard
          Expanded(
            child:
                _words.isEmpty
                    ? const Center(child: Text("No words found."))
                    : GestureDetector(
                      onTap: _flipCard,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final angle = _flipAnimation.value * 3.1416;
                          final isBack = angle > 1.5708;
                          return Transform(
                            transform:
                                Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle),
                            alignment: Alignment.center,
                            child:
                                isBack
                                    ? Transform(
                                      transform:
                                          Matrix4.identity()..rotateY(
                                            3.1416,
                                          ), // flip content back
                                      alignment: Alignment.center,
                                      child: WordCard(
                                        word: _words[_currentIndex].meaning,
                                      ),
                                    )
                                    : WordCard(
                                      word: _words[_currentIndex].word,
                                    ),
                          );
                        },
                      ),
                    ),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _prevCard,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: () {
                    DatabaseHelper.instance.updateWordState(
                      _words[_currentIndex].id!,
                      _words[_currentIndex].learned == 'learned'
                          ? 'learning'
                          : 'learned',
                    );
                  },
                  child: Text('Learned'),
                ),
                ElevatedButton.icon(
                  onPressed: _nextCard,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.word});
  final String word;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            word,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
