import 'package:flutter/material.dart';
import 'package:french_vocabulary_trainer_app/core/database_helper.dart';
import 'package:french_vocabulary_trainer_app/models/model_vocab_word.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  final db = DatabaseHelper.instance;
  List<_WordEntry> entries = [_WordEntry()]; // start with one row

  void _addRow() {
    setState(() {
      entries.add(_WordEntry());
    });
  }

  void _removeRow(int index) {
    setState(() {
      entries.removeAt(index);
    });
  }

  Future<void> _saveAll() async {
    // Validate: remove empty rows
    final toSave =
        entries
            .where(
              (e) =>
                  e.word.text.trim().isNotEmpty &&
                  e.meaning.text.trim().isNotEmpty,
            )
            .toList();

    if (toSave.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter at least one word')));
      return;
    }

    for (final e in toSave) {
      await db.insertWord(
        VocabWord(
          word: e.word.text.trim(),
          meaning: e.meaning.text.trim(),
          category:
              e.category.text.trim().isEmpty ? null : e.category.text.trim(),
          starred: 0,
          learned: 'new',
        ),
      );
    }

    Navigator.pop(context, true); // true means data was added
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert Words'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save all',
            onPressed: _saveAll,
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: entries[index].word,
                    decoration: InputDecoration(
                      labelText: 'French word',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: entries[index].meaning,
                    decoration: InputDecoration(
                      labelText: 'English meaning',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: entries[index].category,
                    decoration: InputDecoration(
                      labelText: 'Category (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (entries.length > 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _removeRow(index),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRow,
        icon: Icon(Icons.add),
        label: Text('Add Another'),
      ),
    );
  }
}

class _WordEntry {
  final word = TextEditingController();
  final meaning = TextEditingController();
  final category = TextEditingController();
}
