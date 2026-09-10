import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smac_comp/main.dart';

// NOTE: these flows stay offline-friendly on purpose — data-dependent
// navigation is covered by screenshots + logic_test.dart, because widget
// tests cannot reach Supabase image CDNs and google_fonts cannot fetch
// weights in this sandbox.

void useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Create goes to family setup, member sheet adds a member', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create your family'));
    await tester.pumpAndSettle();
    expect(find.text('Create your family'), findsWidgets);
    await tester.tap(find.text('Add family member'));
    await tester.pumpAndSettle();
    expect(find.text('Save member'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), 'Test Mom');
    await tester.tap(find.text('Vegetarian').first);
    await tester.pump();
    await tester.tap(find.text('Save member'));
    await tester.pumpAndSettle();
    expect(find.text('Test Mom'), findsOneWidget);
  });

  testWidgets('Reviews tab opens the form and validates empty submit', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('REVIEWS'));
    await tester.pumpAndSettle();
    expect(find.text('New restaurant review'), findsOneWidget);
    await tester.tap(find.textContaining('Add restaurant'));
    await tester.pump();
    expect(find.text('Add the restaurant name first'), findsOneWidget);
  });
}
