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

  const duration = Duration(seconds: 3);

  // Show the snackbar with the determined colors
  final controller = scaffold.showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      duration: duration,
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor),
      ),
      action: SnackBarAction(
        label: 'OK',
        textColor: primaryColor(), // You can also customize this
        onPressed: () => scaffold.removeCurrentSnackBar(),
      ),
    ),
  );

  // ScaffoldMessengerState solo agenda su temporizador interno de
  // auto-cierre cuando, en el momento del build, la ruta dueña de este
  // ScaffoldMessenger es la ruta "current" (ModalRoute.isCurrent). Si el
  // snackbar se muestra mientras hay un diálogo/bottom sheet encima (que
  // empuja una ruta nueva sobre la actual), ese temporizador interno
  // nunca llega a agendarse y el snackbar queda visible indefinidamente
  // hasta que el usuario lo cierra a mano. Para garantizar el auto-cierre
  // siempre —con o sin acción visible— lo forzamos con nuestro propio
  // temporizador, independiente del gating interno de Flutter.
  //
  // Si el snackbar ya se cerró por otro camino antes de que se cumpla
  // este timer (p. ej. el usuario tocó "OK", que llama
  // removeCurrentSnackBar()), `closed` ya se completó y NO hay que volver
  // a llamar controller.close(): hacerlo igual revienta con
  // "Bad state: No element" dentro del propio ScaffoldMessengerState,
  // porque ese snackbar ya salió de su cola interna por el otro lado.
  bool alreadyClosed = false;
  controller.closed.then((_) => alreadyClosed = true);

  Future.delayed(duration, () {
    if (!alreadyClosed) controller.close();
  });
}
