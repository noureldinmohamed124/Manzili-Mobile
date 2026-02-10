import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/theme/app_theme.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/views/signin_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ServicesProvider>(
          create: (_) => ServicesProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Manzili Mobile',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SigninView(),
      ),
    );
  }
}
