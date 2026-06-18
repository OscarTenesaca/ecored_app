import 'package:ecored_app/src/features/charger/presentation/page/page_charger.dart';
import 'package:ecored_app/src/features/charger/presentation/provider/charger_provider.dart';
import 'package:ecored_app/src/features/finance/presentation/page/page_scanqr.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageOptCharger extends StatefulWidget {
  const PageOptCharger({super.key});

  @override
  State<PageOptCharger> createState() => _PageOptChargerState();
}

class _PageOptChargerState extends State<PageOptCharger> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Esperamos a que el widget esté completamente montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChargerProvider>();

      provider
          .getOrderData({'status': "PENDING", "operationStatus": "CHARGING"})
          .then((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChargerProvider>();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.orderData != null) {
      return const PageCharger();
    }

    return const PageScanQr();
  }
}
