
import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyTransaction {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final String note;
  final DateTime date;
  final DateTime? createdAt;

  const MoneyTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.note = '',
    required this.date,
    this.createdAt,
  });

  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory MoneyTransaction.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return MoneyTransaction(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] ?? 'expense',
      category: map['category'] ?? 'Other',
      note: map['note'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
