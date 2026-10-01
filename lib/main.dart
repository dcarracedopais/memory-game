import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() => runApp(const MeriMemory());

class MeriMemory extends StatelessWidget {
  const MeriMemory({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MeriMemory',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7961BC)),
      scaffoldBackgroundColor: const Color(0xFFFFFAF2),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 52)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 52)),
      ),
    ),
    home: const HomeScreen(),
  );
}
