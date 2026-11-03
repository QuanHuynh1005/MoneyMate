
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/main.dart';

void main() {
  testWidgets('MoneyMate app can be created', (WidgetTester tester) async {
    expect(const MoneyMateApp(), isNotNull);
  });
}
