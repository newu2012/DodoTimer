import 'package:dodo_timer/app.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Timer smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // TODO write tests for timer logic
  });
}
