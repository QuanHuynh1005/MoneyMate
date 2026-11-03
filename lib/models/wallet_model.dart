
class MoneyWallet {
  final String id;
  final String name;
  final String type;
  final double initialBalance;
  final int iconCodePoint;
  final int colorValue;
  final DateTime? createdAt;

  const MoneyWallet({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.iconCodePoint,
    required this.colorValue,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'initialBalance': initialBalance,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'createdAt': createdAt,
    };
  }

  factory MoneyWallet.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return MoneyWallet(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? 'cash',
      initialBalance: (map['initialBalance'] as num?)?.toDouble() ?? 0,
      iconCodePoint: map['iconCodePoint'] ?? 0xe8cc,
      colorValue: map['colorValue'] ?? 0xFFE88BAA,
      createdAt: map['createdAt']?.toDate(),
    );
  }
}
