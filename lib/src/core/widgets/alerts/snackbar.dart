import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String content) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      backgroundColor: accentColor(),
      content: Text(content, textAlign: TextAlign.center),
      action: SnackBarAction(
        label: 'OK',
        textColor: primaryColor(),
        onPressed: () {
          scaffold.hideCurrentSnackBar();
        },
      ),
    ),
  );
}
