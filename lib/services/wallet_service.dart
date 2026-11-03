
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/wallet_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _wallets {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wallets');
  }

  // Get all wallets
  Stream<List<MoneyWallet>> getWallets() {
    return _wallets
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MoneyWallet.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Add wallet
  Future<void> addWallet({
    required String name,
    required String type,
    required double initialBalance,
    required int iconCodePoint,
    required int colorValue,
  }) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Wallet name cannot be empty.');
    }

    if (initialBalance < 0) {
      throw Exception('Initial balance cannot be negative.');
    }

    const validTypes = ['cash', 'bank', 'e_wallet', 'other'];

    if (!validTypes.contains(type)) {
      throw Exception('Invalid wallet type.');
    }

    final existing = await _wallets.get();

    final duplicate = existing.docs.any((doc) {
      final existingName =
          (doc.data()['name'] ?? '').toString().trim().toLowerCase();

      return existingName == trimmedName.toLowerCase();
    });

    if (duplicate) {
      throw Exception('A wallet with this name already exists.');
    }

    await _wallets.add({
      'name': trimmedName,
      'type': type,
      'initialBalance': initialBalance,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update wallet
  Future<void> updateWallet({
    required String id,
    required String name,
    required String type,
    required double initialBalance,
    required int iconCodePoint,
    required int colorValue,
  }) async {
    final trimmedName = name.trim();

    if (id.trim().isEmpty) {
      throw Exception('Wallet ID cannot be empty.');
    }

    if (trimmedName.isEmpty) {
      throw Exception('Wallet name cannot be empty.');
    }

    if (initialBalance < 0) {
      throw Exception('Initial balance cannot be negative.');
    }

    const validTypes = ['cash', 'bank', 'e_wallet', 'other'];

    if (!validTypes.contains(type)) {
      throw Exception('Invalid wallet type.');
    }

    final existing = await _wallets.get();

    final duplicate = existing.docs.any((doc) {
      if (doc.id == id) return false;

      final existingName =
          (doc.data()['name'] ?? '').toString().trim().toLowerCase();

      return existingName == trimmedName.toLowerCase();
    });

    if (duplicate) {
      throw Exception('A wallet with this name already exists.');
    }

    await _wallets.doc(id).update({
      'name': trimmedName,
      'type': type,
      'initialBalance': initialBalance,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    });
  }

  // Delete wallet
  Future<void> deleteWallet(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Wallet ID cannot be empty.');
    }

    await _wallets.doc(id).delete();
  }
}
