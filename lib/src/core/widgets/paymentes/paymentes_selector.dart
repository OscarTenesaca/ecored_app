import 'package:ecored_app/src/core/models/payment_model.dart';
import 'package:ecored_app/src/core/services/paymentes_service.dart';
import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class PaymentSelector extends StatelessWidget {
  final String title;
  final Function(PaymentModel) onSelected;

  const PaymentSelector({
    super.key,
    required this.title,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaymentModel>>(
      future: PaymentesServiceImpl().getPaymentMethods(),
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

        return ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF1A1A1A),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (_) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona un método de pago',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...paymentMethods.map((method) {
                        return ListTile(
                          leading:
                              method.img.isNotEmpty
                                  ? Image.network(
                                    method.img,
                                    width: 32,
                                    height: 32,
                                  )
                                  : const Icon(
                                    Icons.payment,
                                    color: Colors.white,
                                  ),
                          title: Text(
                            method.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Comisión: ${method.comission}%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            onSelected(method);
                          },
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor(),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(title, style: const TextStyle(fontSize: 17)),
        );
      },
    );
  }
}
