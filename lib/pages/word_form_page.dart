import 'package:flutter/material.dart';

import '../core/database_helper.dart';
import '../models/model_category.dart';
import '../models/model_vocab_word.dart';

class WordForm extends StatefulWidget {
  final VocabWord? initial;

  const WordForm({super.key, this.initial});

  @override
  State<WordForm> createState() => _WordFormState();
}

class _WordFormState extends State<WordForm> {
  final _wordCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  int? _selectedCategoryId; // store selected category ID

  List<Category> _categories = []; // from DB

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.initial != null) {
      _wordCtrl.text = widget.initial!.word;
      _meaningCtrl.text = widget.initial!.meaning;
      _selectedCategoryId = widget.initial!.categoryId;
    }
  }

  Future<void> _loadCategories() async {
    final db = DatabaseHelper.instance;
    final categories =
        await db.getAllCategories(); // implement this in DB helper
    setState(() {
      _categories = categories;
      if (_selectedCategoryId == null && categories.isNotEmpty) {
        _selectedCategoryId = categories.first.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wordCtrl,
              decoration: const InputDecoration(labelText: 'Word'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _meaningCtrl,
              decoration: const InputDecoration(labelText: 'Meaning'),
            ),
            const SizedBox(height: 12),

            // Category dropdown
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items:
                  _categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategoryId = val;
                });
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_wordCtrl.text.trim().isEmpty ||
                    _meaningCtrl.text.trim().isEmpty ||
                    _selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                Navigator.pop(
                  context,
                  VocabWord(
                    id: widget.initial?.id,
                    word: _wordCtrl.text.trim(),
                    meaning: _meaningCtrl.text.trim(),
                    categoryId: _selectedCategoryId!,
                    starred: widget.initial?.starred ?? 0,
                    learned: widget.initial?.learned ?? 'new',
                  ),
                );
              },
              child: Text(widget.initial == null ? 'Add Word' : 'Update Word'),
            ),
          ],
        ),
      ),
    );
  }
}
