import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_anchor/providers/anchor_provider.dart';
import 'package:w_anchor/screens/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AnchorProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'W Anchor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}