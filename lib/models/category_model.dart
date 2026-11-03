
class MoneyCategory {
  final String id;
  final String name;
  final String type;
  final int iconCodePoint;
  final int colorValue;
  final DateTime? createdAt;

  const MoneyCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorValue,
    this.createdAt,
  });

  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'createdAt': DateTime.now(),
    };
  }

  factory MoneyCategory.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return MoneyCategory(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? 'expense',
      iconCodePoint: map['iconCodePoint'] ?? 0xe8cc,
      colorValue: map['colorValue'] ?? 0xFFE88BAA,
      createdAt: map['createdAt']?.toDate(),
    );
  }
}
