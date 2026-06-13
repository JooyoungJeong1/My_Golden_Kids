import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await rootBundle.load('assets/images/앱로딩.png');
  runApp(const BuriljiMaljiApp());
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class BuriljiMaljiApp extends StatelessWidget {
  const BuriljiMaljiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '버릴래말래',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // 앱 전체 기본 배경색
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFDD835), // 앱 전체 메인 컬러
          surface: const Color(0xFFF6F1F6), // 앱바 배경색
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoTransitionsBuilder(),
            TargetPlatform.iOS: NoTransitionsBuilder(),
            TargetPlatform.windows: NoTransitionsBuilder(),
            TargetPlatform.linux: NoTransitionsBuilder(),
            TargetPlatform.macOS: NoTransitionsBuilder(),
            TargetPlatform.fuchsia: NoTransitionsBuilder(),
          },
        ),
      ),
      home: const SplashScreen(),
    );

    // 웹에서만 앱 너비 430px로 제한
    if (kIsWeb) {
      return Container(
        color: const Color(0xFFEEEEEE),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: app,
          ),
        ),
      );
    }

    return app;
  }
}
