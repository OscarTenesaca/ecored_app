import 'package:ecored_app/src/core/provider/global_injection.dart';
import 'package:ecored_app/src/core/routes/routes.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
      initialRoute: isLoggedIn ? RouteNames.pageAccess : RouteNames.pageLogin,
      theme: ThemeData.from(
        colorScheme: ColorScheme.dark().copyWith(
          primary: accentColor(),
          secondary: accentColor(),
        ),
      ),
      // .copyWith(
      //   textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Montag'),
      // ),
    );
  }
}
