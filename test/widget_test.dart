import 'package:flutter_test/flutter_test.dart';
import 'package:manzili_mobile/main.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(authProvider: AuthProvider()));
    await tester.pump();
    expect(find.textContaining('سجل الدخول'), findsWidgets);
  });
}
