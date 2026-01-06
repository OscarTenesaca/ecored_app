import 'package:ecored_app/src/core/models/nuvei_model.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class PaymentesNuvei extends StatefulWidget {
  const PaymentesNuvei({super.key});

  @override
  State<PaymentesNuvei> createState() => _PaymentesNuveiState();
}

class _PaymentesNuveiState extends State<PaymentesNuvei> {
  late ModelNuvei arg;
  String reference = '';

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      arg = ModalRoute.of(context)?.settings.arguments as ModelNuvei;
      _loadData(arg);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mi HTML")),
      body:
          (reference.isEmpty)
              ? Center(child: CircularProgressIndicator())
              : InAppWebView(
                initialData: InAppWebViewInitialData(data: htmlNuvei),
                onLoadStart: (controller, url) {
                  print("Iniciando carga en: $url");
                },
                onLoadError: (controller, url, code, message) {
                  print(
                    "Error de carga en: $url, código: $code, mensaje: $message",
                  );
                },
                onLoadHttpError: (controller, url, statusCode, description) {
                  print(
                    "Error HTTP en: $url, código: $statusCode, descripción: $description",
                  );
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(
                    "Mensaje en la consola del WebView: ${consoleMessage.message}",
                  );
                },
              ),
    );
  }

  Future<void> _loadData(ModelNuvei args) async {
    final provider = context.read<FinanceProvider>();
    final repNuvei = await provider.postNuveiData(args);
  }

  final String htmlNuvei = '''

        <!DOCTYPE html>
        <html>
        <head>
          <title>Example | Payment Checkout Js</title>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">

          <script src="https://code.jquery.com/jquery-3.5.0.min.js"></script>
          <script src="https://cdn.paymentez.com/ccapi/sdk/payment_checkout_3.0.0.min.js"></script>
        </head>
        <body>
        <button class="js-payment-checkout">Pay with Card</button>

        <div id="response"></div>

        <script>
          let paymentCheckout = new PaymentCheckout.modal({
            env_mode: "stg", // `prod`, `stg`, `local` to change environment. Default is `stg`
            onOpen: function () {
              console.log("modal open");
            },
            onClose: function () {
              console.log("modal closed");
            },
            onResponse: function (response) { // The callback to invoke when the Checkout process is completed

              /*
                In Case of an error, this will be the response.
                response = {
                  "error": {
                    "type": "Server Error",
                    "help": "Try Again Later",
                    "description": "Sorry, there was a problem loading Checkout."
                  }
                }
                When the User completes all the Flow in the Checkout, this will be the response.
                response = {
                  "transaction":{
                      "status": "success", // success or failure
                      "id": "CB-81011", // transaction_id
                      "status_detail": 3 // for the status detail please refer to: https://paymentez.github.io/api-doc/#status-details
                  }
                }
              */
              console.log("modal response");
              document.getElementById("response").innerHTML = JSON.stringify(response);
            }
          });

          let btnOpenCheckout = document.querySelector('.js-payment-checkout');
          btnOpenCheckout.addEventListener('click', function () {
            paymentCheckout.open({
              reference: '8REV4qMyQP3w4xGmANU' // reference received for Payment Gateway
            });
          });

          window.addEventListener('popstate', function () {
            paymentCheckout.close();
          });
        </script>
        </body>
        </html>
  ''';
}
