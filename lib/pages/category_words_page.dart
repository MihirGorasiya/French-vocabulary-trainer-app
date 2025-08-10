import 'package:flutter/material.dart';

import '../core/database_helper.dart';
import '../models/model_category.dart';
import '../models/model_vocab_word.dart';

class CategoryWordsPage extends StatefulWidget {
  const CategoryWordsPage({super.key});

  @override
  State<CategoryWordsPage> createState() => _CategoryWordsPageState();
}

class _CategoryWordsPageState extends State<CategoryWordsPage> {
  final dbHelper = DatabaseHelper.instance;

  List<Category> _categories = [];
  List<VocabWord> _words = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await dbHelper.getAllCategories();
    setState(() {
      _categories = categories;
      if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
      }
    });
    if (_selectedCategoryId != null) {
      _loadWordsByCategory(_selectedCategoryId!);
    }
  }

  Future<void> _loadWordsByCategory(int categoryId) async {
    final words = await dbHelper.getWordsByCategory(categoryId);
    setState(() {
      _words = words;
    });
  }

  void _onCategoryTap(int categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadWordsByCategory(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories & Words")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Categories
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category.id == _selectedCategoryId;
                return GestureDetector(
                  onTap: () => _onCategoryTap(category.id!),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // Words for Selected Category
          Expanded(
            child:
                _words.isEmpty
                    ? const Center(child: Text("No words in this category"))
                    : ListView.builder(
                      itemCount: _words.length,
                      itemBuilder: (context, index) {
                        final word = _words[index];
                        return ListTile(
                          title: Text(word.word),
                          subtitle: Text(word.meaning),
                          trailing: Icon(
                            word.starred == 1
                                ? Icons.star
                                : Icons.star_border_outlined,
                            color:
                                word.starred == 1 ? Colors.amber : Colors.grey,
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
