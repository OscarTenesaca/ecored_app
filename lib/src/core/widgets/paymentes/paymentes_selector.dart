import 'package:ecored_app/src/core/models/payment_model.dart';
import 'package:ecored_app/src/core/services/paymentes_service.dart';
import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/widgets/background/background_glass.dart';
import 'package:flutter/material.dart';

enum PaymentSelectorType { button, card }

class PaymentSelector extends StatefulWidget {
  final PaymentSelectorType type;
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;
  final Function(PaymentModel) onSelected;

  const PaymentSelector({
    super.key,
    required this.title,
    required this.onSelected,
    this.type = PaymentSelectorType.button,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.black,
  });

  @override
  State<PaymentSelector> createState() => _PaymentSelectorState();
}

class _PaymentSelectorState extends State<PaymentSelector> {
  /// 👇 Estado liviano, sin setState
  final ValueNotifier<PaymentModel?> selectedMethod =
      ValueNotifier<PaymentModel?>(null);

  late final Future<List<PaymentModel>> _paymentMethodsFuture;

  @override
  void initState() {
    super.initState();
    _paymentMethodsFuture =
        PaymentesServiceImpl().getPaymentMethods(); // solo una vez
  }

  @override
  void dispose() {
    selectedMethod.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor == Colors.transparent
            ? accentColor()
            : widget.backgroundColor;

    return FutureBuilder<List<PaymentModel>>(
      future: _paymentMethodsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text(
            'Error al cargar métodos de pago',
            style: TextStyle(color: Colors.red),
          );
        }

        final paymentMethods = snapshot.data ?? [];

        if (paymentMethods.isEmpty) {
          return const Text(
            'No hay métodos de pago disponibles',
            style: TextStyle(color: Colors.white),
          );
        }

        switch (widget.type) {
          case PaymentSelectorType.button:
            return _buildButtonSelector(context, bgColor, paymentMethods);

          case PaymentSelectorType.card:
            return _buildCardSelector(paymentMethods);
        }
      },
    );
  }

  // ─────────────────────────────
  // BOTÓN → ABRE BOTTOM SHEET
  // ─────────────────────────────
  Widget _buildButtonSelector(
    BuildContext context,
    Color bgColor,
    List<PaymentModel> paymentMethods,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: widget.foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1A1A1A),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children:
                  paymentMethods.map((method) {
                    return ListTile(
                      leading: const Icon(Icons.payment, color: Colors.white),
                      title: Text(
                        method.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Comisión: ${method.comission}%',
                        style: TextStyle(color: Colors.white.withOpacity(0.6)),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        selectedMethod.value = method;
                        widget.onSelected(method);
                      },
                    );
                  }).toList(),
            );
          },
        );
      },
      child: Text(widget.title, style: const TextStyle(fontSize: 17)),
    );
  }

  // ─────────────────────────────
  // CARDS CON RADIO (REACTIVO)
  // ─────────────────────────────
  Widget _buildCardSelector(List<PaymentModel> paymentMethods) {
    return Container(
      decoration: cardDecoration(shadow: true),
      padding: const EdgeInsets.all(16),
      child: ValueListenableBuilder<PaymentModel?>(
        valueListenable: selectedMethod,
        builder: (context, value, _) {
          return Column(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: grayInputColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...paymentMethods.map((method) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: greyColorWithTransparency().withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.payment, color: Colors.white),
                    title: Text(
                      method.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Comisión: ${method.comission}%',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    trailing: Radio<PaymentModel>(
                      value: method,
                      groupValue: value,
                      activeColor: accentColor(),
                      onChanged: (_) {
                        selectedMethod.value = method;
                        widget.onSelected(method);
                      },
                    ),
                    onTap: () {
                      selectedMethod.value = method;
                      widget.onSelected(method);
                    },
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

// import 'package:ecored_app/src/core/models/payment_model.dart';
// import 'package:ecored_app/src/core/services/paymentes_service.dart';
// import 'package:ecored_app/src/core/theme/theme_colors.dart';
// import 'package:ecored_app/src/core/widgets/background/background_glass.dart';
// import 'package:flutter/material.dart';

// enum PaymentSelectorType { button, card }

// class PaymentSelector extends StatefulWidget {
//   final PaymentSelectorType type;
//   final String title;
//   final Color backgroundColor;
//   final Color foregroundColor;
//   final Function(PaymentModel) onSelected;

//   const PaymentSelector({
//     super.key,
//     required this.title,
//     required this.onSelected,
//     this.type = PaymentSelectorType.button,
//     this.backgroundColor = Colors.transparent,
//     this.foregroundColor = Colors.black,
//   });

//   @override
//   State<PaymentSelector> createState() => _PaymentSelectorState();
// }

// class _PaymentSelectorState extends State<PaymentSelector> {
//   PaymentModel? selectedMethod;

//   late Future<List<PaymentModel>> _paymentMethodsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _paymentMethodsFuture =
//         PaymentesServiceImpl().getPaymentMethods(); // 👈 solo una vez
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bgColor =
//         widget.backgroundColor == Colors.transparent
//             ? accentColor()
//             : widget.backgroundColor;

//     return FutureBuilder<List<PaymentModel>>(
//       future: _paymentMethodsFuture, // 👈 FUTURE CACHEADO
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return const Text(
//             'Error al cargar métodos de pago',
//             style: TextStyle(color: Colors.red),
//           );
//         }

//         final paymentMethods = snapshot.data ?? [];

//         if (paymentMethods.isEmpty) {
//           return const Text(
//             'No hay métodos de pago disponibles',
//             style: TextStyle(color: Colors.white),
//           );
//         }

//         switch (widget.type) {
//           case PaymentSelectorType.button:
//             return _buildButtonSelector(context, bgColor, paymentMethods);

//           case PaymentSelectorType.card:
//             return _buildCardSelector(paymentMethods);
//         }
//       },
//     );
//   }

//   // ─────────────────────────────
//   // BOTÓN → ABRE BOTTOM SHEET
//   // ─────────────────────────────
//   Widget _buildButtonSelector(
//     BuildContext context,
//     Color bgColor,
//     List<PaymentModel> paymentMethods,
//   ) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: bgColor,
//         foregroundColor: widget.foregroundColor,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//       onPressed: () {
//         showModalBottomSheet(
//           context: context,
//           backgroundColor: const Color(0xFF1A1A1A),
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           builder: (_) {
//             return ListView(
//               padding: const EdgeInsets.all(16),
//               children:
//                   paymentMethods.map((method) {
//                     return ListTile(
//                       leading: const Icon(Icons.payment, color: Colors.white),
//                       title: Text(
//                         method.name,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       subtitle: Text(
//                         'Comisión: ${method.comission}%',
//                         style: TextStyle(color: Colors.white.withOpacity(0.6)),
//                       ),
//                       onTap: () {
//                         Navigator.pop(context);
//                         widget.onSelected(method);
//                       },
//                     );
//                   }).toList(),
//             );
//           },
//         );
//       },
//       child: Text(widget.title, style: const TextStyle(fontSize: 17)),
//     );
//   }

//   // ─────────────────────────────
//   // CARDS CON RADIO (SOLO RADIO VERDE)
//   // ─────────────────────────────
//   Widget _buildCardSelector(List<PaymentModel> paymentMethods) {
//     return Container(
//       decoration: cardDecoration(shadow: true),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children:
//             paymentMethods.map((method) {
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 6),
//                 color: greyColorWithTransparency().withValues(alpha: 0.2),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: ListTile(
//                   leading: const Icon(Icons.payment, color: Colors.white),
//                   title: Text(
//                     method.name,
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   subtitle: Text(
//                     'Comisión: ${method.comission}%',
//                     style: TextStyle(color: Colors.white.withOpacity(0.6)),
//                   ),
//                   trailing: Radio<PaymentModel>(
//                     value: method,
//                     groupValue: selectedMethod,
//                     activeColor: accentColor(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedMethod = value;
//                       });
//                       widget.onSelected(method);
//                     },
//                   ),
//                   onTap: () {
//                     setState(() {
//                       selectedMethod = method;
//                     });
//                     widget.onSelected(method);
//                   },
//                 ),
//               );
//             }).toList(),
//       ),
//     );
//   }
// }
