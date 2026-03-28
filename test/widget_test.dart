import 'package:flutter_test/flutter_test.dart';
import 'package:manzili_mobile/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.textContaining('سجل الدخول'), findsWidgets);
  });
}
