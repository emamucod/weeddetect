import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeddetectapp/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          userEmail: 'test@example.com',
        ), // Added required param
      ),
    );

    // Verify the screen loads
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
