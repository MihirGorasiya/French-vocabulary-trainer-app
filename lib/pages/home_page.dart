import 'package:flutter/material.dart';
import 'package:french_vocabulary_trainer_app/models/model_vocab_word.dart';
import 'package:french_vocabulary_trainer_app/pages/insert_page.dart';
import 'package:french_vocabulary_trainer_app/pages/word_form_page.dart';
import 'package:provider/provider.dart';

import '../provider/word_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _addOrEditWord(
    BuildContext context, {
    VocabWord? existing,
  }) async {
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
      final provider = Provider.of<WordProvider>(context, listen: false);
      if (existing == null) {
        await provider.addWord(result);
      } else {
        await provider.updateWord(result.copyWith(id: existing.id));
      }
    }
  }

  void _toggleStar(BuildContext context, VocabWord w) {
    Provider.of<WordProvider>(
      context,
      listen: false,
    ).toggleStar(w.id!, w.starred == 0);
  }

  void _deleteWord(BuildContext context, VocabWord w) async {
    final provider = Provider.of<WordProvider>(context, listen: false);
    await provider.deleteWord(w.id!);
    final snack = SnackBar(
      content: Text('Deleted "${w.word}"'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () async {
          await provider.addWord(w.copyWith(id: null));
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  @override
  Widget build(BuildContext context) {
    final wordProvider = Provider.of<WordProvider>(context);
    final words = wordProvider.words;
    final loading = wordProvider.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('French Vocab'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => wordProvider.loadWords(),
          ),
        ],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () => wordProvider.loadWords(),
                child:
                    words.isEmpty
                        ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
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
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: words.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final w = words[index];
                            return Dismissible(
                              key: ValueKey(w.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) => _deleteWord(context, w),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  w.word,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      w.meaning,
                                      style: const TextStyle(fontSize: 15),
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
                                      )
                                    else
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
                                      onPressed: () => _toggleStar(context, w),
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                                onTap:
                                    () => _addOrEditWord(context, existing: w),
                              ),
                            );
                          },
                        ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InsertPage()),
          );
          if (added == true) {
            wordProvider.loadWords();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new word',
      ),
    );
  }
}
