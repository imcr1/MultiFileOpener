// Smoke test: the app builds and shows its main screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:multifileopener/src/controllers/opener_controller.dart';
import 'package:multifileopener/src/views/home_view.dart';

void main() {
  testWidgets('Home view renders core controls', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = OpenerController();
    await controller.init();

    await tester.pumpWidget(
      MaterialApp(home: HomeView(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('MultiFileOpener'), findsOneWidget);
    expect(find.text('Pick PDFs'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('No target app selected'), findsOneWidget);
  });
}
