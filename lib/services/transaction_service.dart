
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _transactions {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  // Get all transactions of current user
  Stream<List<MoneyTransaction>> getTransactions() {
    return _transactions
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MoneyTransaction.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Add transaction
  Future<void> addTransaction(MoneyTransaction transaction) async {
    if (transaction.title.trim().isEmpty) {
      throw Exception('Transaction title is required.');
    }

    if (transaction.amount <= 0) {
      throw Exception('Amount must be greater than zero.');
    }

    if (!['income', 'expense'].contains(transaction.type)) {
      throw Exception('Invalid transaction type.');
    }

    await _transactions.add(transaction.toMap());
  }

  // Update transaction
  Future<void> updateTransaction(
    MoneyTransaction transaction,
  ) async {
    if (transaction.title.trim().isEmpty) {
      throw Exception('Transaction title is required.');
    }

    if (transaction.amount <= 0) {
      throw Exception('Amount must be greater than zero.');
    }

    if (!['income', 'expense'].contains(transaction.type)) {
      throw Exception('Invalid transaction type.');
    }

    await _transactions
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    if (transactionId.trim().isEmpty) {
      throw Exception('Transaction ID is required.');
    }

    await _transactions.doc(transactionId).delete();
  }
}
