import 'package:flutter_test/flutter_test.dart';
import 'package:main_app/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MarginaliaApp());
    expect(find.text('Marginalia'), findsOneWidget);
  });
}
