
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _categories {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('categories');
  }

  // Get all categories
  Stream<List<MoneyCategory>> getCategories() {
    return _categories
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MoneyCategory.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Get categories by type
  Stream<List<MoneyCategory>> getCategoriesByType(String type) {
    if (!['income', 'expense'].contains(type)) {
      throw Exception('Invalid category type.');
    }

    return _categories
        .where('type', isEqualTo: type)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MoneyCategory.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Add category
  Future<void> addCategory(MoneyCategory category) async {
    final name = category.name.trim();

    if (name.isEmpty) {
      throw Exception('Category name is required.');
    }

    if (!['income', 'expense'].contains(category.type)) {
      throw Exception('Invalid category type.');
    }

    final existing = await _categories
        .where('type', isEqualTo: category.type)
        .get();

    final isDuplicate = existing.docs.any(
      (doc) =>
          (doc.data()['name'] as String?)
              ?.trim()
              .toLowerCase() ==
          name.toLowerCase(),
    );

    if (isDuplicate) {
      throw Exception('This category already exists.');
    }

    final newCategory = MoneyCategory(
      id: '',
      name: name,
      type: category.type,
      iconCodePoint: category.iconCodePoint,
      colorValue: category.colorValue,
    );

    await _categories.add(newCategory.toMap());
  }

  // Update category
  Future<void> updateCategory(MoneyCategory category) async {
    final name = category.name.trim();

    if (category.id.trim().isEmpty) {
      throw Exception('Category ID is required.');
    }

    if (name.isEmpty) {
      throw Exception('Category name is required.');
    }

    if (!['income', 'expense'].contains(category.type)) {
      throw Exception('Invalid category type.');
    }

    final existing = await _categories
        .where('type', isEqualTo: category.type)
        .get();

    final isDuplicate = existing.docs.any(
      (doc) =>
          doc.id != category.id &&
          (doc.data()['name'] as String?)
              ?.trim()
              .toLowerCase() ==
          name.toLowerCase(),
    );

    if (isDuplicate) {
      throw Exception('This category already exists.');
    }

    await _categories.doc(category.id).update({
      'name': name,
      'type': category.type,
      'iconCodePoint': category.iconCodePoint,
      'colorValue': category.colorValue,
    });
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    if (categoryId.trim().isEmpty) {
      throw Exception('Category ID is required.');
    }

    await _categories.doc(categoryId).delete();
  }
}
