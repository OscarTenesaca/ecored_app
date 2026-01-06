// import 'package:ecored_app/src/core/theme/theme_index.dart';
// import 'package:flutter/material.dart';

// void showSnackbar(BuildContext context, String content) {
//   final scaffold = ScaffoldMessenger.of(context);
//   scaffold.showSnackBar(
//     SnackBar(
//       backgroundColor: accentColor(),
//       content: Text(content, textAlign: TextAlign.center),
//       action: SnackBarAction(
//         label: 'OK',
//         textColor: primaryColor(),
//         onPressed: () {
//           scaffold.hideCurrentSnackBar();
//         },
//       ),
//     ),
//   );
// }

import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/material.dart';

enum SnackbarStatus { success, waiting, error }

void showSnackbar(BuildContext context, String content, SnackbarStatus status) {
  final scaffold = ScaffoldMessenger.of(context);

  Color backgroundColor;
  Color textColor = Colors.white; // Default color for text

  // Define the color based on the status
  switch (status) {
    case SnackbarStatus.success:
      backgroundColor = Colors.green; // Green for success
      break;
    case SnackbarStatus.waiting:
      backgroundColor = Colors.orange; // Orange for waiting
      textColor =
          Colors.black; // Optional: you can set a different color for waiting
      break;
    case SnackbarStatus.error:
      backgroundColor = Colors.red; // Red for error
      break;
  }

  // Show the snackbar with the determined colors
  scaffold.showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor),
      ),
      action: SnackBarAction(
        label: 'OK',
        textColor: primaryColor(), // You can also customize this
        onPressed: () {
          scaffold.hideCurrentSnackBar();
        },
      ),
    ),
  );
}
