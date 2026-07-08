import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kreyol_plus/main.dart';

void main() {
  testWidgets('Login page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that we are on the login page by checking for the logo text
    expect(find.text('Kreyòl+'), findsOneWidget);
    
    // Check for username and password fields
    expect(find.byType(TextField), findsNWidgets(2));
    
    // Check for login button
    expect(find.text('Se connecter'), findsOneWidget);
    
    // Check for signup link
    expect(find.text('S\'inscrire'), findsOneWidget);
  });
}

