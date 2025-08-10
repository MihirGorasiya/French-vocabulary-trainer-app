import 'package:french_vocabulary_trainer_app/models/model_vocab_word.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'vocab.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL,
        category TEXT,
        starred INTEGER DEFAULT 0,
        learned TEXT DEFAULT 'new'
      );
    ''');
  }

  Future<int> insertWord(VocabWord w) async {
    final db = await database;
    final map = w.toMap();
    // Remove id if null so sqlite autoincrements
    map.removeWhere((k, v) => k == 'id' && v == null);
    return await db.insert('words', map);
  }

  Future<int> updateWord(VocabWord w) async {
    final db = await database;
    return await db.update(
      'words',
      w.toMap(),
      where: 'id = ?',
      whereArgs: [w.id],
    );
  }

  Future<int> deleteWord(int id) async {
    final db = await database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<VocabWord>> getAllWords() async {
    final db = await database;
    final rows = await db.query('words', orderBy: 'word COLLATE NOCASE ASC');
    return rows.map((r) => VocabWord.fromMap(r)).toList();
  }
}
