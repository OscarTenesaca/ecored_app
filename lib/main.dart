import 'package:ecored_app/src/core/provider/global_injection.dart';
import 'package:ecored_app/src/core/routes/routes.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/features/charger/charger_injection.dart';
import 'package:ecored_app/src/features/finance/finance_injection.dart';
import 'package:ecored_app/src/features/login/data/models/model_user.dart';
import 'package:ecored_app/src/features/login/login_injection.dart';
import 'package:ecored_app/src/features/maps/station_injection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// void main() => runApp(const MyApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences().init();
  runApp(
    MultiProvider(
      providers: [
        ...globalProvider,
        ...loginProviders,
        ...stationProvider,
        ...financeProviders,
        ...chargerProvider,
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Preferences pref = Preferences();
    final ModelUser? user = pref.getUser();
    final bool isLoggedIn = user?.token != null && user!.token.isNotEmpty;
    // print(user?.toJson());
    // print('Is user logged in? ${user?.token}');

    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   routes: appRoutes,
    //   initialRoute: isLoggedIn ? RouteNames.pageAccess : RouteNames.pageLogin,
    //   theme: ThemeData.from(
    //     colorScheme: ColorScheme.dark().copyWith(
    //       primary: accentColor(),
    //       secondary: accentColor(),
    //     ),
    //   ),
    //   // .copyWith(
    //   //   textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Montag'),
    //   // ),
    // );
    final colorScheme = ColorScheme.dark().copyWith(
      primary: accentColor(),
      secondary: accentColor(),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
      initialRoute: isLoggedIn ? RouteNames.pageAccess : RouteNames.pageLogin,
      // `fontFamily` en el constructor de ThemeData hace que Flutter
      // derive su propio textTheme/primaryTextTheme con Sora ya
      // aplicado a cada estilo (bodyLarge, titleMedium, labelLarge...).
      // Reforzamos textTheme/primaryTextTheme explícitamente para que
      // quede garantizado incluso si algo más adelante reemplaza el
      // textTheme derivado por uno propio.
      //
      // Sora reemplaza a Jumper: la versión gratuita de Jumper tenía los
      // 10 dígitos reemplazados a propósito por el watermark del
      // diseñador para forzar la compra de la licencia comercial. Sora
      // es de Google Fonts (licencia OFL, gratis para uso comercial) y
      // tiene el set de glifos completo — ver pubspec.yaml.
      theme: ThemeData(
        colorScheme: colorScheme,
        fontFamily: 'Sora',
        textTheme: ThemeData.from(
          colorScheme: colorScheme,
        ).textTheme.apply(fontFamily: 'Sora'),
        primaryTextTheme: ThemeData.from(
          colorScheme: colorScheme,
        ).primaryTextTheme.apply(fontFamily: 'Sora'),
      ),
    );
  }
}
