import 'package:ecored_app/src/core/routes/routes.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
      initialRoute: RouteNames.pageLogin,
      theme: ThemeData.from(
        colorScheme: ColorScheme.dark().copyWith(
          primary: accentColor(),
          secondary: accentColor(),
        ),
      ),
      // .copyWith(
      //   textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'YaroRg'),
      // ),
    );
  }
}
