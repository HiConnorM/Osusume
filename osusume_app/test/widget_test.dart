import 'package:flutter_test/flutter_test.dart';
import 'package:osusume_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OsusumeApp());
    expect(find.byType(OsusumeApp), findsOneWidget);
  });
}
