import 'package:flutter/material.dart';

import '../core/database_helper.dart';
import '../models/model_vocab_word.dart';

class WordProvider with ChangeNotifier {
  List<VocabWord> _words = [];
  bool _loading = false;

  List<VocabWord> get words => _words;
  bool get loading => _loading;

  /// Load all words from the database
  Future<void> loadWords() async {
    _loading = true;
    notifyListeners();
    final data = await DatabaseHelper.instance.getAllWords();
    _words = data;
    _loading = false;
    notifyListeners();
  }

  /// Add a new word
  Future<void> addWord(VocabWord word) async {
    await DatabaseHelper.instance.insertWord(word);
    await loadWords();
  }

  /// Update an existing word
  Future<void> updateWord(VocabWord word) async {
    await DatabaseHelper.instance.updateWord(word);
    await loadWords();
  }

  /// Delete a word by ID
  Future<void> deleteWord(int id) async {
    await DatabaseHelper.instance.deleteWord(id);
    await loadWords();
  }

  /// Update the 'learned' state
  Future<void> updateWordState(int id, String state) async {
    await DatabaseHelper.instance.updateWordState(id, state);
    await loadWords();
  }

  /// Toggle the 'starred' field
  Future<void> toggleStar(int id, bool isStarred) async {
    await DatabaseHelper.instance.updateStar(id, isStarred);
    await loadWords();
  }

  Future<void> loadWordsByCategory(int categoryId) async {
    final data = await DatabaseHelper.instance.getWordsByCategory(categoryId);
    _words = data;
    notifyListeners();
  }
}
