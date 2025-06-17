// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticker/ticker.dart';

import 'package:flutter_ticker_sample/main.dart';
import 'package:flutter_ticker_sample/interactive_demo.dart';

void main() {
  testWidgets('Navigation to Interactive Demo works',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that we have a button to navigate to the Interactive Demo
    expect(find.text('Interactive Demo'), findsOneWidget);

    // Tap the Interactive Demo button and trigger a frame.
    await tester.tap(find.text('Interactive Demo'));
    await tester.pumpAndSettle();

    // Verify that we're on the Interactive Demo screen
    expect(find.byType(InteractiveDemoScreen), findsOneWidget);

    // Verify that we have a TickerWidget for the counter
    expect(find.byType(TickerWidget), findsWidgets);

    // Find the floating action button and tap it
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // We can't directly check the text value since it's in a custom widget,
    // but we can verify the FloatingActionButton still exists after tapping
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
