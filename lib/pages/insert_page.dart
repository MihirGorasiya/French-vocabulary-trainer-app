import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:french_vocabulary_trainer_app/core/database_helper.dart';
import 'package:french_vocabulary_trainer_app/models/model_category.dart';
import 'package:french_vocabulary_trainer_app/models/model_vocab_word.dart';
import 'package:provider/provider.dart';

import '../providers/provider_category.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  final db = DatabaseHelper.instance;
  List<_WordEntry> entries = [_WordEntry()]; // start with one row

  @override
  void initState() {
    super.initState();
    // Load categories when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

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
          categoryId: e.selectedCategoryId ?? 0,
          starred: 0,
          learned: 'new',
        ),
      );
    }

    Navigator.pop(context, true); // true means data was added
  }

  Future<void> importWordsFromExcel(DatabaseHelper db) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return; // User canceled

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Importing words from Excel...\nWait for a moment, you will be redirected automatically.',
        ),
      ),
    );

    File file = File(result.files.single.path!);
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    for (var sheetName in excel.tables.keys) {
      var sheet = excel.tables[sheetName];
      if (sheet == null) continue;

      bool firstRow = true; // If you want to skip headers
      for (var row in sheet.rows) {
        if (firstRow) {
          firstRow = false;
          continue; // skip header row
        }

        final frenchWord = row[0]?.value?.toString().trim() ?? '';
        final englishWord = row[1]?.value?.toString().trim() ?? '';
        final categoryName = row[2]?.value?.toString().trim() ?? '';

        if (frenchWord.isEmpty || englishWord.isEmpty) continue;

        List<Category> categories = await db.getAllCategories();
        int categoryId = -1;

        for (Category category in categories) {
          if (category.name.trim().toLowerCase() ==
              categoryName.toString().trim().toLowerCase()) {
            categoryId = category.id!;
          }
        }
        if (categoryId == -1) {
          categoryId = await db.insertCategory(
            Category(name: categoryName.toString().trim().toLowerCase()),
          );
        }

        await db.insertWord(
          VocabWord(
            word: frenchWord,
            meaning: englishWord,
            categoryId: categoryId,
          ),
        );
      }
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
            icon: Icon(Icons.import_export),
            tooltip: 'Import',
            onPressed: () async => await importWordsFromExcel(db),
          ),
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
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      final categories = categoryProvider.categories;
                      return DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        value: entries[index].selectedCategoryId,
                        items:
                            categories.map((Category category) {
                              return DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            entries[index].selectedCategoryId = value;
                          });
                        },
                      );
                    },
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
  int? selectedCategoryId; // NEW — dropdown selected value
}
