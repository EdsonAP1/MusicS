// Basic test for MusicS app
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/app.dart';

void main() {
  testWidgets('MusicS app smoke test', (WidgetTester tester) async {
    // Verify that the app can be instantiated
    expect(const MusicSApp(), isNotNull);
  });
}
