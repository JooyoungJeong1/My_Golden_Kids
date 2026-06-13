import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            if (kIsWeb) {
              // 웹 전용 - ConstrainedBox로 앱 너비 제한
              return Scaffold(
                backgroundColor: const Color(0xFFEEEEEE),
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: const MainScreen(),
                  ),
                ),
              );
            } else {
              // 앱 전용 - 바로 MainScreen
              return const MainScreen();
            }
          },
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200), // 이미지 크기 제한
          child: Image.asset('assets/images/앱로딩.png'),
        ),
      ),
    );
  }
}
