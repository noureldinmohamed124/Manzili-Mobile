import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:manzili_mobile/core/router/app_router.dart';
import 'package:manzili_mobile/core/theme/app_theme.dart';
import 'package:manzili_mobile/l10n/app_localizations.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/providers/cart_provider.dart';
import 'package:manzili_mobile/presentation/providers/orders_provider.dart';
import 'package:manzili_mobile/presentation/providers/seller_provider.dart';
import 'package:manzili_mobile/presentation/providers/favourites_provider.dart';
import 'package:manzili_mobile/presentation/providers/theme_provider.dart';
import 'package:manzili_mobile/presentation/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ServicesProvider>(
          create: (_) => ServicesProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<OrdersProvider>(create: (_) => OrdersProvider()),
        ChangeNotifierProvider<SellerProvider>(create: (_) => SellerProvider()),
        ChangeNotifierProvider<FavouritesProvider>(
          create: (_) => FavouritesProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp.router(
            title: 'منزلي',
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: MyApp._router,
          );
        },
      ),
    );
  }
}
