import 'package:flutter/material.dart';

/// Returns the height of the screen.
double sizeHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

/// Returns the width of the screen.
double sizeWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

/// Returns half the width of the screen if it is greater than 500, otherwise returns [double.infinity].
double sizeMiddle(BuildContext context) {
  double width = sizeWidth(context);
  return width > 500 ? width / 2 : double.infinity;
}

/// Returns the status bar height.
double statusBarHeight(BuildContext context) {
  return MediaQuery.of(context).padding.top;
}

/// Returns horizontal margins based on screen width.
EdgeInsets marginApp(BuildContext context) =>
    EdgeInsets.symmetric(horizontal: sizeWidth(context) * 0.02);
