import 'package:flutter/material.dart';
import 'package:french_vocabulary_trainer_app/core/database_helper.dart';
import 'package:french_vocabulary_trainer_app/models/model_vocab_word.dart';
import 'package:french_vocabulary_trainer_app/pages/insert_page.dart';
import 'package:french_vocabulary_trainer_app/pages/word_form_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = DatabaseHelper.instance;
  List<VocabWord> _words = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    setState(() => _loading = true);
    final words = await db.getAllWords();
    setState(() {
      _words = words;
      _loading = false;
    });
  }

  Future<void> _addOrEditWord({VocabWord? existing}) async {
    // show modal bottom sheet with form
    final result = await showModalBottomSheet<VocabWord>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: WordForm(initial: existing),
        );
      },
    );

    if (result != null) {
      if (existing == null) {
        await db.insertWord(result);
      } else {
        await db.updateWord(result.copyWith(id: existing.id));
      }
      await _loadWords();
    }
  }

  void _toggleStar(VocabWord w) async {
    final toggled = w.copyWith(starred: w.starred == 1 ? 0 : 1);
    await db.updateWord(toggled);
    final idx = _words.indexWhere((e) => e.id == w.id);
    if (idx >= 0) {
      setState(() => _words[idx] = toggled);
    } else {
      _loadWords();
    }
  }

  void _deleteWord(VocabWord w) async {
    await db.deleteWord(w.id!);
    setState(() => _words.removeWhere((e) => e.id == w.id));
    final snack = SnackBar(
      content: Text('Deleted "${w.word}"'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () async {
          await db.insertWord(w.copyWith(id: null)); // reinsert (new id)
          _loadWords();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('French Vocab'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh),
            onPressed: _loadWords,
          ),
          // future: add search / category icons here
        ],
      ),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadWords,
                child:
                    _words.isEmpty
                        ? ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 120),
                            Icon(
                              Icons.menu_book_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                'No words yet. Tap + to add your first word.',
                              ),
                            ),
                          ],
                        )
                        : ListView.separated(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: _words.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final w = _words[index];
                            return Dismissible(
                              key: ValueKey(w.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) => _deleteWord(w),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  w.word,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(
                                      w.meaning,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    if (w.category != null &&
                                        (w.category?.isNotEmpty ?? false))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 6.0,
                                        ),
                                        child: Wrap(
                                          spacing: 6,
                                          children: [
                                            Chip(label: Text(w.category!)),
                                            Chip(label: Text(w.learned)),
                                          ],
                                        ),
                                      ),
                                    if (w.category == null ||
                                        w.category!.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 6.0,
                                        ),
                                        child: Chip(label: Text(w.learned)),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip:
                                          w.starred == 1 ? 'Unstar' : 'Star',
                                      icon: Icon(
                                        w.starred == 1
                                            ? Icons.star
                                            : Icons.star_border,
                                        color:
                                            w.starred == 1
                                                ? Colors.amber
                                                : null,
                                      ),
                                      onPressed: () => _toggleStar(w),
                                    ),
                                    Icon(Icons.chevron_right),
                                  ],
                                ),
                                onTap: () => _addOrEditWord(existing: w),
                              ),
                            );
                          },
                        ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => InsertPage()),
          );
          if (added == true) {
            _loadWords();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add new word',
      ),
    );
  }
}
