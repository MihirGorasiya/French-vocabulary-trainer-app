class VocabWord {
  final int? id;
  final String word;
  final String meaning;
  final int categoryId;
  final String? categoryName;
  final int starred; // 0 or 1
  final String learned; // 'new', 'learning', 'learned'

  VocabWord({
    this.id,
    required this.word,
    required this.meaning,
    required this.categoryId,
    this.categoryName,
    this.starred = 0,
    this.learned = 'new',
  });

  factory VocabWord.fromMap(Map<String, dynamic> m) => VocabWord(
    id: m['id'] as int?,
    word: m['word'] as String,
    meaning: m['meaning'] as String,
    categoryId: m['category_id'] as int,
    categoryName: m['category_name'],
    starred: m['starred'] as int? ?? 0,
    learned: m['state'] as String? ?? 'new',
  );

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'meaning': meaning,
      'category_id': categoryId,
      'category_name': categoryName,
      'starred': starred,
      'state': learned,
      if (id != null) 'id': id,
    };
  }

  VocabWord copyWith({
    int? id,
    String? word,
    String? meaning,
    int? categoryId,
    String? categoryName,
    int? starred,
    String? learned,
  }) {
    return VocabWord(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      starred: starred ?? this.starred,
      learned: learned ?? this.learned,
    );
  }
}
