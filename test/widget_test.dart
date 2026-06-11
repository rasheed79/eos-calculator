import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_01_end_of_service/main.dart';

void main() {
  testWidgets('calculator smoke test: input -> calculate -> result card', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const EndOfServiceApp());

    expect(find.text('احسب مكافأتك'), findsOneWidget);
    expect(find.text('احسب الآن'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '10000');
    await tester.enterText(find.byType(TextField).at(1), '7');

    await tester.ensureVisible(find.text('احسب الآن'));
    await tester.tap(find.text('احسب الآن'));
    await tester.pumpAndSettle();

    expect(find.text('إجمالي مكافأة نهاية الخدمة'), findsOneWidget);
    expect(find.text('مكافأة كاملة'), findsWidgets);
  });
}
