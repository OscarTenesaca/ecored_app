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
  final ValueNotifier<PaymentModel?> selectedMethod =
      ValueNotifier<PaymentModel?>(null);

  late final Future<List<PaymentModel>> _paymentMethodsFuture;

  @override
  void initState() {
    super.initState();

    _paymentMethodsFuture = PaymentesServiceImpl().getPaymentMethods();
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
            "Error cargando métodos de pago",
            style: TextStyle(color: Colors.red),
          );
        }

        final methods = snapshot.data ?? [];

        if (methods.isEmpty) {
          return const Text(
            "No hay métodos disponibles",
            style: TextStyle(color: Colors.white),
          );
        }

        switch (widget.type) {
          case PaymentSelectorType.button:
            return _buildButtonSelector(context, bgColor, methods);

          case PaymentSelectorType.card:
            return _buildCardSelector(methods);
        }
      },
    );
  }

  //=====================================================
  // BUTTON
  //=====================================================

  Widget _buildButtonSelector(
    BuildContext context,
    Color bgColor,
    List<PaymentModel> methods,
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

          backgroundColor: const Color(0xff090D09),

          isScrollControlled: true,

          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),

          builder: (_) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * .75,

              child: _buildPaymentContent(methods, closeSheet: true),
            );
          },
        );
      },

      child: Text(widget.title, style: const TextStyle(fontSize: 17)),
    );
  }

  //=====================================================
  // CARD
  //=====================================================

  Widget _buildCardSelector(List<PaymentModel> methods) {
    return Container(
      decoration: cardDecoration(shadow: true),

      padding: const EdgeInsets.all(16),

      child: _buildPaymentContent(methods, closeSheet: false),
    );
  }

  //=====================================================
  // UI COMPARTIDA
  //=====================================================

  Widget _buildPaymentContent(
    List<PaymentModel> methods, {
    required bool closeSheet,
  }) {
    return ValueListenableBuilder<PaymentModel?>(
      valueListenable: selectedMethod,

      builder: (context, selected, _) {
        return Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "Selecciona un método",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 24,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "Elige cómo deseas realizar el pago",

                  style: TextStyle(color: Colors.white60),
                ),
              ),

              const SizedBox(height: 20),

              Flexible(
                child: ListView.separated(
                  itemCount: methods.length,

                  separatorBuilder: (_, __) => const SizedBox(height: 14),

                  itemBuilder: (context, index) {
                    final method = methods[index];

                    final isSelected = selected == method;

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),

                      onTap: () {
                        selectedMethod.value = method;

                        if (closeSheet) {
                          Navigator.pop(context);
                        }

                        widget.onSelected(method);
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),

                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? accentColor().withValues(alpha: .15)
                                  : const Color(0xff181D18),

                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(
                            color: isSelected ? accentColor() : Colors.white12,

                            width: 1.4,
                          ),
                        ),

                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,

                              backgroundColor:
                                  isSelected ? accentColor() : Colors.white10,

                              child: Icon(
                                Icons.payment,

                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    method.name,

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 18,

                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    "Comisión ${method.comission}%",

                                    style: const TextStyle(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: 24,

                              height: 24,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                border: Border.all(
                                  color:
                                      isSelected
                                          ? accentColor()
                                          : Colors.white24,

                                  width: 2,
                                ),
                              ),

                              child:
                                  isSelected
                                      ? Center(
                                        child: Container(
                                          width: 10,

                                          height: 10,

                                          decoration: BoxDecoration(
                                            color: accentColor(),

                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

//!opt1
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
//   final ValueNotifier<PaymentModel?> selectedMethod =
//       ValueNotifier<PaymentModel?>(null);

//   late final Future<List<PaymentModel>> _paymentMethodsFuture;

//   @override
//   void initState() {
//     super.initState();

//     _paymentMethodsFuture = PaymentesServiceImpl().getPaymentMethods();
//   }

//   @override
//   void dispose() {
//     selectedMethod.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bgColor =
//         widget.backgroundColor == Colors.transparent
//             ? accentColor()
//             : widget.backgroundColor;

//     return FutureBuilder<List<PaymentModel>>(
//       future: _paymentMethodsFuture,

//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return const Text(
//             "Error cargando métodos de pago",
//             style: TextStyle(color: Colors.red),
//           );
//         }

//         final methods = snapshot.data ?? [];

//         if (methods.isEmpty) {
//           return const Text(
//             "No hay métodos disponibles",
//             style: TextStyle(color: Colors.white),
//           );
//         }

//         switch (widget.type) {
//           case PaymentSelectorType.button:
//             return _buildButtonSelector(context, bgColor, methods);

//           case PaymentSelectorType.card:
//             return _buildCardSelector(methods);
//         }
//       },
//     );
//   }

//   // ======================================================
//   // BUTTON
//   // ======================================================

//   Widget _buildButtonSelector(
//     BuildContext context,
//     Color bgColor,
//     List<PaymentModel> methods,
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

//           backgroundColor: const Color(0xff090D09),

//           isScrollControlled: true,

//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
//           ),

//           builder: (_) {
//             return SizedBox(
//               height: MediaQuery.of(context).size.height * .75,

//               child: _buildPaymentContent(methods, closeSheet: true),
//             );
//           },
//         );
//       },

//       child: Text(widget.title, style: const TextStyle(fontSize: 17)),
//     );
//   }

//   // ======================================================
//   // CARD
//   // ======================================================

//   Widget _buildCardSelector(List<PaymentModel> methods) {
//     return Container(
//       decoration: cardDecoration(shadow: true),

//       padding: const EdgeInsets.all(16),

//       child: _buildPaymentContent(methods, closeSheet: false),
//     );
//   }

//   // ======================================================
//   // UI COMPARTIDA
//   // BUTTON + CARD
//   // ======================================================

//   Widget _buildPaymentContent(
//     List<PaymentModel> methods, {
//     required bool closeSheet,
//   }) {
//     return ValueListenableBuilder<PaymentModel?>(
//       valueListenable: selectedMethod,

//       builder: (context, selected, _) {
//         return Padding(
//           padding: const EdgeInsets.all(20),

//           child: Column(
//             children: [
//               const Align(
//                 alignment: Alignment.centerLeft,

//                 child: Text(
//                   "Selecciona un método",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 8),

//               const Align(
//                 alignment: Alignment.centerLeft,

//                 child: Text(
//                   "Elige cómo deseas realizar el pago",
//                   style: TextStyle(color: Colors.white60),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               Expanded(
//                 child: ListView.separated(
//                   itemCount: methods.length,

//                   separatorBuilder: (_, __) => const SizedBox(height: 14),

//                   itemBuilder: (context, index) {
//                     final method = methods[index];

//                     final isSelected = selected == method;

//                     return InkWell(
//                       borderRadius: BorderRadius.circular(18),

//                       onTap: () {
//                         selectedMethod.value = method;
//                       },

//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 250),

//                         padding: const EdgeInsets.all(18),

//                         decoration: BoxDecoration(
//                           color:
//                               isSelected
//                                   ? accentColor().withOpacity(.15)
//                                   : const Color(0xff181D18),

//                           borderRadius: BorderRadius.circular(18),

//                           border: Border.all(
//                             color: isSelected ? accentColor() : Colors.white12,

//                             width: 1.4,
//                           ),
//                         ),

//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 25,

//                               backgroundColor:
//                                   isSelected ? accentColor() : Colors.white10,

//                               child: Icon(
//                                 Icons.payment,

//                                 color: isSelected ? Colors.black : Colors.white,
//                               ),
//                             ),

//                             const SizedBox(width: 16),

//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,

//                                 children: [
//                                   Text(
//                                     method.name,

//                                     style: const TextStyle(
//                                       color: Colors.white,

//                                       fontSize: 18,

//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),

//                                   const SizedBox(height: 5),

//                                   Text(
//                                     "Comisión ${method.comission}%",

//                                     style: const TextStyle(
//                                       color: Colors.white60,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             Container(
//                               width: 24,

//                               height: 24,

//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,

//                                 border: Border.all(
//                                   color:
//                                       isSelected
//                                           ? accentColor()
//                                           : Colors.white24,

//                                   width: 2,
//                                 ),
//                               ),

//                               child:
//                                   isSelected
//                                       ? Center(
//                                         child: Container(
//                                           width: 10,

//                                           height: 10,

//                                           decoration: BoxDecoration(
//                                             color: accentColor(),

//                                             shape: BoxShape.circle,
//                                           ),
//                                         ),
//                                       )
//                                       : null,
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(height: 20),

//               SizedBox(
//                 width: double.infinity,

//                 height: 56,

//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: accentColor(),

//                     foregroundColor: Colors.black,

//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),

//                   onPressed:
//                       selected == null
//                           ? null
//                           : () {
//                             if (closeSheet) {
//                               Navigator.pop(context);
//                             }

//                             widget.onSelected(selected);
//                           },

//                   child: const Text(
//                     "Continuar",

//                     style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//!old
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
//   /// 👇 Estado liviano, sin setState
//   final ValueNotifier<PaymentModel?> selectedMethod =
//       ValueNotifier<PaymentModel?>(null);

//   late final Future<List<PaymentModel>> _paymentMethodsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _paymentMethodsFuture =
//         PaymentesServiceImpl().getPaymentMethods(); // solo una vez
//   }

//   @override
//   void dispose() {
//     selectedMethod.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bgColor =
//         widget.backgroundColor == Colors.transparent
//             ? accentColor()
//             : widget.backgroundColor;

//     return FutureBuilder<List<PaymentModel>>(
//       future: _paymentMethodsFuture,
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
//             return ValueListenableBuilder<PaymentModel?>(
//               valueListenable: selectedMethod,
//               builder: (context, selected, _) {
//                 return ListView.separated(
//                   padding: const EdgeInsets.all(20),
//                   itemCount: paymentMethods.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 14),
//                   itemBuilder: (context, index) {
//                     final method = paymentMethods[index];

//                     final isSelected = selected == method;

//                     return InkWell(
//                       borderRadius: BorderRadius.circular(18),
//                       onTap: () {
//                         selectedMethod.value = method;

//                         Navigator.pop(context);

//                         widget.onSelected(method);
//                       },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 250),
//                         padding: const EdgeInsets.all(18),
//                         decoration: BoxDecoration(
//                           color: accentColor().withOpacity(.15),

//                           // color:
//                           // isSelected
//                           //     ? accentColor().withOpacity(.15)
//                           //     : const Color(0xff181D18),
//                           borderRadius: BorderRadius.circular(18),
//                           border: Border.all(
//                             color: accentColor(),
//                             // color: isSelected ? accentColor() : Colors.white12,
//                             width: 1.4,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 25,
//                               backgroundColor: accentColor(),
//                               // isSelected ? accentColor() : Colors.white10,
//                               child: Icon(
//                                 getIcon(method.name),
//                                 color: Colors.black,
//                                 // color: isSelected ? Colors.black : Colors.white,
//                               ),
//                             ),

//                             const SizedBox(width: 16),

//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     method.name,
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 18,
//                                     ),
//                                   ),

//                                   const SizedBox(height: 5),

//                                   Text(
//                                     "Comisión ${method.comission}%",
//                                     style: const TextStyle(
//                                       color: Colors.white60,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // AnimatedContainer(
//                             //   duration: const Duration(milliseconds: 250),
//                             //   width: 24,
//                             //   height: 24,
//                             //   decoration: BoxDecoration(
//                             //     shape: BoxShape.circle,
//                             //     border: Border.all(
//                             //       color:
//                             //           isSelected
//                             //               ? accentColor()
//                             //               : Colors.white24,
//                             //       width: 2,
//                             //     ),
//                             //   ),
//                             //   child:
//                             //       isSelected
//                             //           ? Center(
//                             //             child: Container(
//                             //               width: 10,
//                             //               height: 10,
//                             //               decoration: BoxDecoration(
//                             //                 color: accentColor(),
//                             //                 shape: BoxShape.circle,
//                             //               ),
//                             //             ),
//                             //           )
//                             //           : null,
//                             // ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//             // return ListView(
//             //   padding: const EdgeInsets.all(16),
//             //   children:
//             //       paymentMethods.map((method) {
//             //         return ListTile(
//             //           leading: const Icon(Icons.payment, color: Colors.white),
//             //           title: Text(
//             //             method.name,
//             //             style: const TextStyle(color: Colors.white),
//             //           ),
//             //           subtitle: Text(
//             //             'Comisión: ${method.comission}%',
//             //             style: TextStyle(color: Colors.white.withOpacity(0.6)),
//             //           ),
//             //           onTap: () {
//             //             Navigator.pop(context);
//             //             selectedMethod.value = method;
//             //             widget.onSelected(method);
//             //           },
//             //         );
//             //       }).toList(),
//             // );
//           },
//         );
//       },
//       child: Text(widget.title, style: const TextStyle(fontSize: 17)),
//     );
//   }

//   // ─────────────────────────────
//   // CARDS CON RADIO (REACTIVO)
//   // ─────────────────────────────
//   Widget _buildCardSelector(List<PaymentModel> paymentMethods) {
//     return Container(
//       decoration: cardDecoration(shadow: true),
//       padding: const EdgeInsets.all(16),
//       child: ValueListenableBuilder<PaymentModel?>(
//         valueListenable: selectedMethod,
//         builder: (context, value, _) {
//           return Column(
//             children: [
//               Text(
//                 widget.title,
//                 style: TextStyle(
//                   color: grayInputColor(),
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               ...paymentMethods.map((method) {
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 6),
//                   color: greyColorWithTransparency().withValues(alpha: 0.2),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ListTile(
//                     leading: const Icon(Icons.payment, color: Colors.white),
//                     title: Text(
//                       method.name,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                     subtitle: Text(
//                       'Comisióneeess: ${method.comission}%',
//                       style: TextStyle(color: Colors.white.withOpacity(0.6)),
//                     ),
//                     trailing: Radio<PaymentModel>(
//                       value: method,
//                       groupValue: value,
//                       activeColor: accentColor(),
//                       onChanged: (_) {
//                         selectedMethod.value = method;
//                         widget.onSelected(method);
//                       },
//                     ),
//                     onTap: () {
//                       selectedMethod.value = method;
//                       widget.onSelected(method);
//                     },
//                   ),
//                 );
//               }).toList(),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// IconData getIcon(String name) {
//   switch (name.toLowerCase()) {
//     case 'nuvei':
//       return Icons.credit_card;
//     case 'payphone':
//       return Icons.phone_android;
//     case 'transferencia':
//       return Icons.account_balance;
//     case 'efectivo':
//       return Icons.payments;
//     default:
//       return Icons.payment;
//   }
// }
