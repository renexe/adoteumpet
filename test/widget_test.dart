import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoteumpet/main.dart';

void main() {
  testWidgets('App smoke test — verifica que o app inicia corretamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AdoteUmPetApp(),
      ),
    );
    expect(find.byType(AdoteUmPetApp), findsOneWidget);
  });
}
