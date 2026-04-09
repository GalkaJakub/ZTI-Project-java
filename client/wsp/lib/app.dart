import 'package:flutter/material.dart';
import 'features/home/home_shell.dart';

class WspolnicyApp extends StatelessWidget {
  const WspolnicyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wspólnicy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}