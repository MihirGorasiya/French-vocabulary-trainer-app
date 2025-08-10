import 'package:flutter/material.dart';
import 'package:french_vocabulary_trainer_app/models/model_vocab_word.dart';

class WordForm extends StatefulWidget {
  final VocabWord? initial;
  WordForm({this.initial});

  @override
  _WordFormState createState() => _WordFormState();
}

class _WordFormState extends State<WordForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _wordCtrl;
  late TextEditingController _meaningCtrl;
  late TextEditingController _categoryCtrl;
  bool _starred = false;
  String _learned = 'new';

  @override
  void initState() {
    super.initState();
    _wordCtrl = TextEditingController(text: widget.initial?.word ?? '');
    _meaningCtrl = TextEditingController(text: widget.initial?.meaning ?? '');
    _categoryCtrl = TextEditingController(text: widget.initial?.category ?? '');
    _starred = (widget.initial?.starred ?? 0) == 1;
    _learned = widget.initial?.learned ?? 'new';
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newWord = VocabWord(
      id: widget.initial?.id,
      word: _wordCtrl.text.trim(),
      meaning: _meaningCtrl.text.trim(),
      category:
          _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
      starred: _starred ? 1 : 0,
      learned: _learned,
    );

    Navigator.of(context).pop(newWord);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'Edit word' : 'Add new word',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _wordCtrl,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      labelText: 'French word',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Enter the French word'
                                : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _meaningCtrl,
                    decoration: InputDecoration(
                      labelText: 'English meaning',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Enter the meaning'
                                : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryCtrl,
                    decoration: InputDecoration(
                      labelText: 'Category (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _starred,
                        onChanged: (v) => setState(() => _starred = v ?? false),
                      ),
                      Text('Star this word'),
                      Spacer(),
                      DropdownButton<String>(
                        value: _learned,
                        items:
                            ['new', 'learning', 'learned']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _learned = v ?? 'new'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(isEditing ? 'Save changes' : 'Add word'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
