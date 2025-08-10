class VocabWord {
  final int? id;
  final String word;
  final String meaning;
  final String? category;
  final int starred; // 0 or 1
  final String learned; // 'new', 'learning', 'learned'

  VocabWord({
    this.id,
    required this.word,
    required this.meaning,
    this.category,
    this.starred = 0,
    this.learned = 'new',
  });

  factory VocabWord.fromMap(Map<String, dynamic> m) => VocabWord(
        id: m['id'] as int?,
        word: m['word'] as String,
        meaning: m['meaning'] as String,
        category: m['category'] as String?,
        starred: m['starred'] as int? ?? 0,
        learned: m['learned'] as String? ?? 'new',
      );

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'meaning': meaning,
      'category': category,
      'starred': starred,
      'learned': learned,
      if (id != null) 'id': id,
    };
  }

  VocabWord copyWith({
    int? id,
    String? word,
    String? meaning,
    String? category,
    int? starred,
    String? learned,
  }) {
    return VocabWord(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      category: category ?? this.category,
      starred: starred ?? this.starred,
      learned: learned ?? this.learned,
    );
  }
}
