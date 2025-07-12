import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class UtilSize {
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double sizeMiddle(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width > 500 ? width / 2 : double.infinity;
  }

  static double appBarHeight() => AppBar().preferredSize.height;

  static double statusBarHeight() {
    final view = PlatformDispatcher.instance.views.first;
    return view.padding.top / view.devicePixelRatio;
  }

  static double bottomPadding() {
    final view = PlatformDispatcher.instance.views.first;
    return view.padding.bottom / view.devicePixelRatio;
  }
}
