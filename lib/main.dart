import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/app.dart';
import 'package:matrix_terminal/core/background/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundServiceManager.init();
  runApp(
    const ProviderScope(
      child: MatrixTerminalApp(),
    ),
  );
}
