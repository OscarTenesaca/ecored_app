import 'package:flutter/material.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';

///PAGES
import 'package:ecored_app/src/features/login/presentation/pages/page_login.dart';

final Map<String, WidgetBuilder> appRoutes = {
  RouteNames.pageLogin: (_) => const PageLogin(),
  // RouteNames.initLogin: (_) => const InitLoginPage(),
};
