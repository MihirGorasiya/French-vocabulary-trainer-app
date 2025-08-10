import 'package:flutter/material.dart';

import '../core/database_helper.dart';
import '../models/model_category.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  /// Load all categories from DB
  Future<void> loadCategories() async {
    final data = await DatabaseHelper.instance.getAllCategories();
    _categories = data;
    notifyListeners();
  }

  /// Add a new category
  Future<void> addCategory(String name) async {
    final category = Category(name: name);
    await DatabaseHelper.instance.insertCategory(category);
    await loadCategories();
  }

  /// Update an existing category
  Future<void> updateCategory(int id, String newName) async {
    final category = Category(id: id, name: newName);
    await DatabaseHelper.instance.updateCategory(category);
    await loadCategories();
  }

  /// Delete a category
  Future<void> deleteCategory(int id) async {
    await DatabaseHelper.instance.deleteCategory(id);
    await loadCategories();
  }
}
