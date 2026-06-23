import 'package:flutter/material.dart';

import 'src/controllers/opener_controller.dart';
import 'src/views/home_view.dart';
import 'src/views/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = OpenerController();
  controller.init();
  runApp(MultiFileOpenerApp(controller: controller));
}

/// App entry — wires the single [OpenerController] to the [HomeView].
class MultiFileOpenerApp extends StatelessWidget {
  const MultiFileOpenerApp({super.key, required this.controller});

  final OpenerController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiFileOpener',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      themeMode: ThemeMode.light,
      home: HomeView(controller: controller),
    );
  }
}
