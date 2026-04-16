import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BuriljiMaljiApp());
}

class BuriljiMaljiApp extends StatelessWidget {
  const BuriljiMaljiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '버릴래말래',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // 앱 전체 기본 배경색
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFDD835), // 앱 전체 메인 컬러
          surface: const Color(0xFFF6F1F6), // 앱바 배경색
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
