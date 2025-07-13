import 'package:flutter/material.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';

///PAGES
import 'package:ecored_app/src/features/login/presentation/pages/page_login.dart';
import 'package:ecored_app/src/features/access/presentation/page/page_access.dart';
import 'package:ecored_app/src/features/home/presentation/page/page_home.dart';
import 'package:ecored_app/src/features/maps/presentation/page/page_maps.dart';
import 'package:ecored_app/src/features/finance/presentation/page/page_finance.dart';
import 'package:ecored_app/src/features/profile/presentation/page/page_profile.dart';

final Map<String, WidgetBuilder> appRoutes = {
  RouteNames.pageLogin: (_) => const PageLogin(),

  RouteNames.pageAccess: (_) => const PageAccess(),
  RouteNames.pageHome: (_) => const PageHome(),
  RouteNames.pageMap: (_) => const PageMaps(),
  RouteNames.pageFinance: (_) => const PageFinance(),
  RouteNames.pageProfile: (_) => const PageProfile(),
};
