import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/features/host/screens/host_list_screen.dart';

class MatrixTerminalApp extends StatelessWidget {
  const MatrixTerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrix Terminal',
      theme: AppTheme.dark,
      home: const HostListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
