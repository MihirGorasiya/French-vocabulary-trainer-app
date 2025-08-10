// lib/db/database_helper.dart

import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/model_category.dart';
import '../models/model_vocab_word.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vocab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // bumped version for migration
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL,
        category_id INTEGER,
        starred INTEGER NOT NULL,
        state TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');
      await db.execute('ALTER TABLE words ADD COLUMN category_id INTEGER');
    }
  }

  // ----------------- CATEGORY CRUD -----------------
  Future<List<Category>> getCategories() async {
    final db = await database;
    final result = await db.query('categories'); // adjust table name if needed
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final maps = await db.query('categories', orderBy: 'name ASC');

    // return result.map((map) => Category.fromMap(map)).toList();
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<int> updateCategory(Category category) async {
    final db = await instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ----------------- WORD CRUD -----------------
  Future<int> insertWord(VocabWord word) async {
    final db = await instance.database;

    return await db.insert('words', {
      'word': word.word,
      'meaning': word.meaning,
      'category_id': word.categoryId,
      'starred': word.starred,
      'state': word.learned,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<VocabWord>> getAllWords({int? categoryId}) async {
    // final db = await instance.database;
    // final result =
    //     categoryId != null
    //         ? await db.query(
    //           'words',
    //           where: 'category_id = ?',
    //           whereArgs: [categoryId],
    //           orderBy: 'word ASC',
    //         )
    //         : await db.query('words', orderBy: 'word ASC');
    //
    // return result.map((map) => VocabWord.fromMap(map)).toList();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT words.*, categories.name as category_name
    FROM words
    LEFT JOIN categories ON words.category_id = categories.id
  ''');
    return List.generate(maps.length, (i) => VocabWord.fromMap(maps[i]));
  }

  Future<List<VocabWord>> getWordsByCategory(int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return VocabWord.fromMap(maps[i]);
    });
  }

  Future<List<VocabWord>> getWordsByCategoryAndLearning(int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'category_id = ? AND (state = "learning" OR state = "new")',
      whereArgs: [categoryId],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return VocabWord.fromMap(maps[i]);
    });
  }

  Future<List<VocabWord>> getWordsByCategoryAndLearned() async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'state = "learned"',
      // whereArgs: [categoryId],
      // orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return VocabWord.fromMap(maps[i]);
    });
  }

  Future<int> updateWord(VocabWord word) async {
    final db = await instance.database;
    return await db.update(
      'words',
      {
        'word': word.word,
        'meaning': word.meaning,
        'category_id': word.categoryId,
        'starred': word.starred,
        'state': word.learned,
      },
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<int> updateWordState(int id, String state) async {
    final db = await instance.database;
    final res = await db.update(
      'words',
      {'state': state},
      where: 'id = ?',
      whereArgs: [id],
    );
    return res;
  }

  Future<int> updateStar(int id, bool isStarred) async {
    final db = await instance.database;
    return await db.update(
      'words',
      {'starred': isStarred ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteWord(int id) async {
    final db = await instance.database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }
}
