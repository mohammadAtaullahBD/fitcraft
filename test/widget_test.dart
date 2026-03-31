import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitcraft/app/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FitCraftApp(),
      ),
    );

    // Give the router time to redirect to the login screen since the user isn't authenticated
    await tester.pumpAndSettle();

    // Verify the app renders the Login screen since we are unauthenticated.
    expect(find.text('Log In'), findsWidgets);
  });
}
