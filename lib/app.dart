import 'package:flutter/material.dart';
import 'package:tugas_ki/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encrypt Decrypt Demo',
      theme: ThemeData(colorScheme: const ColorScheme.dark()),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}
