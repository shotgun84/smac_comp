import 'package:flutter_test/flutter_test.dart';

import 'package:smac_comp/main.dart';

void main() {
  testWidgets('Familia landing renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Familia'), findsOneWidget);
    expect(find.text('Create your family'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
