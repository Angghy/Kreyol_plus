import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kreyol_plus/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the signup link, verify signup screen',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we start on the Login screen
      expect(find.text('Kreyòl+'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);

      // Find and tap the signup link
      final signupLink = find.text('S\'inscrire');
      await tester.tap(signupLink);

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Verify that we are on the signup screen
      expect(find.text('Créer un compte'), findsOneWidget);
      expect(find.text('Confirmer le mot de passe'), findsOneWidget);
    });
  });
}
