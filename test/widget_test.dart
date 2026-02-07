import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/app.dart';

void main() {
  testWidgets('App renders host list screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MatrixTerminalApp(),
      ),
    );

    expect(find.text('Hosts'), findsWidgets);
    expect(find.text('No hosts yet'), findsOneWidget);
  });
}
