import 'package:flutter_test/flutter_test.dart';
import 'package:wsp/app.dart';

void main() {
  testWidgets('shows the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WspolnicyApp());

    expect(find.text('Wspólnicy'), findsOneWidget);
    expect(find.text('Zaloguj się'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Hasło'), findsOneWidget);
  });
}
