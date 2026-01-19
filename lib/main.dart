import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/theme/app_theme.dart';
import 'package:manzili_mobile/presentation/views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manzili Mobile',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeView(),
    );
  }
}
