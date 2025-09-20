// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:watdagam/main.dart';
import 'package:watdagam/data/repositories/graffiti_repository.dart';
import 'package:watdagam/data/datasources/mock_graffiti_datasource.dart';

void main() {
  testWidgets('Graffiti wall loads successfully', (WidgetTester tester) async {
    // Create repository with mock data source for testing
    final repository = GraffitiRepository(MockGraffitiDataSource());

    // Build our app and trigger a frame.
    await tester.pumpWidget(WatdagamApp(repository: repository));

    // Verify that our app loads
    expect(find.text('낙서집・0개 낙서'), findsOneWidget);

    // Wait for data to load
    await tester.pumpAndSettle();

    // Should show loaded notes count
    expect(find.textContaining('낙서집・'), findsOneWidget);
  });
}
