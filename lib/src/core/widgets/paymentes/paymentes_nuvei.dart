import 'package:ecored_app/src/core/models/nuvei_model.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/alerts/popup.dart';
import 'package:ecored_app/src/core/widgets/alerts/snackbar.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

enum PaymentStatus { recharge, order }

class PaymentesNuvei extends StatefulWidget {
  final ModelNuvei bodyNuvei;
  final Map<String, dynamic> bodyEcored;
  final PaymentStatus status;

  const PaymentesNuvei({
    super.key,
    required this.bodyNuvei,
    required this.bodyEcored,
    required this.status,
  });

  @override
  State<PaymentesNuvei> createState() => _PaymentesNuveiState();
}

class _PaymentesNuveiState extends State<PaymentesNuvei> {
  String reference = '';
  bool _checkoutOpened = false;
  bool _resultHandled = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadData(widget.bodyNuvei);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago Nuvei')),
      body:
          reference.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : InAppWebView(
                initialData: InAppWebViewInitialData(data: _htmlNuvei()),
                onWebViewCreated: (controller) {
                  // 🔥 RECIBE RESULTADO DEL PAGO
                  controller.addJavaScriptHandler(
                    handlerName: 'paymentResult',
                    callback: (args) async {
                      final result = args.first as Map<String, dynamic>;
                      await _handlePaymentResult(result);
                    },
                  );
                },
                onLoadStop: (controller, url) async {
                  if (!_checkoutOpened) {
                    _checkoutOpened = true;
                    await controller.evaluateJavascript(
                      source: """
                    paymentCheckout.open({
                      reference: "$reference"
                    });
                  """,
                    );
                  }
                },
                shouldOverrideUrlLoading: (controller, action) async {
                  final uri = action.request.url;
                  final scheme = uri?.scheme.toLowerCase();
                  // Solo se permite navegar dentro del WebView por HTTPS
                  // (los redirects de 3DS del banco pueden ir a dominios
                  // distintos, por eso no se restringe a una lista fija).
                  if (scheme == 'https' || scheme == 'about') {
                    return NavigationActionPolicy.ALLOW;
                  }
                  return NavigationActionPolicy.CANCEL;
                },
              ),
    );
  }

  // ========================
  // BACKEND NUVEI
  // ========================
  Future<void> _loadData(ModelNuvei args) async {
    final provider = context.read<FinanceProvider>();
    final Map repNuvei = await provider.postNuveiData(args);

    if (repNuvei['statusCode'] == 200) {
      setState(() {
        reference = repNuvei['data']['reference'];
      });
    } else {
      if (!mounted) return;
      showSnackbar(
        context,
        'Error al procesar el pago: ${repNuvei['message']}',
        SnackbarStatus.error,
      );
    }
  }

  // ========================
  // CONTROL DE ESTADO PAGO
  // ========================
  Future<void> _handlePaymentResult(Map<String, dynamic> result) async {
    if (_resultHandled) return;
    _resultHandled = true;

    final transaction = result['transaction'];
    if (transaction is! Map) {
      if (!mounted) return;
      showSnackbar(
        context,
        'No se pudo leer la respuesta del pago. Intente nuevamente.',
        SnackbarStatus.error,
      );
      return;
    }

    widget.bodyEcored['authorizationCode'] =
        transaction['authorization_code'] ?? '';
    widget.bodyEcored['transactionId'] = transaction['id'] ?? '';

    final bool isApproved =
        transaction['status'] == 'success' &&
        transaction['current_status'] == 'APPROVED';

    if (isApproved) {
      switch (widget.status) {
        case PaymentStatus.recharge:
          await _consumeEcoredApi(result);
          break;
        case PaymentStatus.order:
          await _consumeOrder(result);
          break;
      }
    } else {
      showSnackbar(
        context,
        'El pago no fue aprobado. Intente nuevamente.',
        SnackbarStatus.error,
      );
    }
  }

  // ========================
  // CONSUME API ECORED FOR RECHARGE
  // ========================
  Future<void> _consumeEcoredApi(Map paymentData) async {
    final provider = context.read<FinanceProvider>();

    final response = await provider.postRecharge(widget.bodyEcored);

    if (response == 201) {
      if (!mounted) return;
      showPopUpWithChildren(
        context: context,
        title: 'Pago exitoso',
        subTitle: 'Su pago ha sido procesado correctamente.',
        textButton: 'Aceptar',
        onSubmit: () {
          // Se capturan antes de navegar: tras el segundo pop esta
          // pantalla puede quedar desmontada y su context ya no es válido.
          final refreshProvider = context.read<FinanceProvider>();
          final userId = Preferences().getUser()?.id;

          Navigator.pop(context); // Cierra el popup
          Navigator.pop(context, true); // Retorna al screen anterior

          // Refresca los datos de la wallet y transacciones
          refreshProvider.getWalletData({'user': userId});
          refreshProvider.getTransactionData({'user': userId});
        },
      );
    } else {
      if (!mounted) return;
      showSnackbar(
        context,
        'Pago aprobado, pero falló Ecored. Código de respuesta: $response',
        SnackbarStatus.error,
      );
    }
  }

  // ========================
  // CONSUME API ECORED FOR ORDER
  // ========================

  Future<void> _consumeOrder(Map paymentData) async {
    final provider = context.read<FinanceProvider>();

    final response = await provider.postOrderPayment(widget.bodyEcored);

    if (response == 201) {
      if (!mounted) return;
      showPopUpWithChildren(
        context: context,
        title: 'Pago exitoso',
        subTitle: 'Su pago ha sido procesado correctamente.',
        textButton: 'Aceptar',
        onSubmit: () {
          // Se capturan antes de navegar: tras el segundo pop esta
          // pantalla puede quedar desmontada y su context ya no es válido.
          final refreshProvider = context.read<FinanceProvider>();
          final userId = Preferences().getUser()?.id;

          Navigator.pop(context); // Cierra el popup
          Navigator.pop(context, true); // Retorna al screen anterior

          // Refresca los datos de la wallet y transacciones
          refreshProvider.getWalletData({'user': userId});
          refreshProvider.getTransactionData({'user': userId});
        },
      );
    } else {
      if (!mounted) return;
      showSnackbar(
        context,
        'Pago aprobado, pero falló Ecored. Código de respuesta: $response',
        SnackbarStatus.error,
      );
    }
  }

  // ========================
  // HTML
  // ========================
  String _htmlNuvei() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <title>Nuvei Checkout</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <script src="https://code.jquery.com/jquery-3.5.0.min.js"></script>
  <script src="https://cdn.paymentez.com/ccapi/sdk/payment_checkout_3.0.0.min.js"></script>
</head>
<body>

<script>
  window.paymentCheckout = new PaymentCheckout.modal({
    env_mode: "stg",
    onResponse: function (response) {
      // 🔥 ENVÍA RESPUESTA A FLUTTER
      window.flutter_inappwebview.callHandler(
        'paymentResult',
        response
      );
    }
  });
</script>

</body>
</html>
''';
  }
}


// import 'dart:convert';

// import 'package:ecored_app/src/core/models/nuvei_model.dart';
// import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:provider/provider.dart';

// class PaymentesNuvei extends StatefulWidget {
//   final ModelNuvei bodyNuvei;
//   final Map<String, dynamic> bodyEcored;

//   const PaymentesNuvei({
//     super.key,
//     required this.bodyNuvei,
//     required this.bodyEcored,
//   });

//   @override
//   State<PaymentesNuvei> createState() => _PaymentesNuveiState();
// }

// class _PaymentesNuveiState extends State<PaymentesNuvei> {
//   // late ModelNuvei arg;
//   String reference = '';

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () {
//       _loadData(widget.bodyNuvei);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Pago Nuvei')),
//       body:
//           reference.isEmpty
//               ? const Center(child: CircularProgressIndicator())
//               : InAppWebView(
//                 initialData: InAppWebViewInitialData(
//                   data: _htmlNuvei(reference),
//                 ),
//                 onLoadStart: (controller, url) {
//                   debugPrint('Iniciando carga: $url');
//                 },

//                 onConsoleMessage: (controller, consoleMessage) {
//                   // diferencais si esta bn o o malo si esta bn consume la api de ecored caso contrario muestra error
//                   debugPrint('Mensaje de consola: ${consoleMessage.message}');

//                   final response = jsonDecode(consoleMessage.message);

//                   debugPrint('Response decoded: $response');
//                   // Aquí puedes manejar el mensaje de consola como
//                 },
//               ),
//     );
//   }

//   Future<void> _loadData(ModelNuvei args) async {
//     final provider = context.read<FinanceProvider>();
//     final Map repNuvei = await provider.postNuveiData(args);

//     if (repNuvei['statusCode'] == 200) {
//       setState(() {
//         reference = repNuvei['data']['reference'];
//       });
//     } else {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error al procesar el pago: ${repNuvei['message']}'),
//         ),
//       );
//     }
//   }

//   String _htmlNuvei(String reference) {
//     return '''
//       <!DOCTYPE html>
//       <html>
//       <head>
//         <title>Nuvei Checkout</title>
//         <meta charset="UTF-8">
//         <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
//         <script src="https://code.jquery.com/jquery-3.5.0.min.js"></script>
//         <script src="https://cdn.paymentez.com/ccapi/sdk/payment_checkout_3.0.0.min.js"></script>
//       </head>
//       <body>
    
//       <div id="response"></div>
    
//       <script>
//         let paymentCheckout = new PaymentCheckout.modal({
//           env_mode: "stg",
//           onOpen: function () {
//             console.log("modal open");
//           },
//           onClose: function () {
//             console.log("modal closed");
//           },
//           onResponse: function (response) {
//             console.log("modal response");
//             document.getElementById("response").innerHTML = JSON.stringify(response);
//           }
//         });
    
//         // ⬇️ ABRE AUTOMÁTICAMENTE EL CHECKOUT
//         document.addEventListener("DOMContentLoaded", function () {
//           paymentCheckout.open({
//             reference: "$reference"
//           });
//         });
//       </script>
    
//       </body>
//       </html>
//   ''';
//   }
// }
