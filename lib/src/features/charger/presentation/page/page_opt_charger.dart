import 'package:ecored_app/src/features/charger/presentation/page/page_charger.dart';
import 'package:ecored_app/src/features/charger/presentation/provider/charger_provider.dart';
import 'package:ecored_app/src/features/finance/presentation/page/page_scanqr.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageOptCharger extends StatefulWidget {
  final ValueListenable<int>? tabIndexNotifier;
  final int? ownTabIndex;

  const PageOptCharger({
    super.key,
    this.tabIndexNotifier,
    this.ownTabIndex,
  });

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

    // Un error real de red/servidor no es lo mismo que "no hay carga
    // activa": no se debe mandar directo al escáner sin avisar.
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No se pudo verificar si tienes una carga activa.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                provider
                    .getOrderData({
                      'status': "PENDING",
                      "operationStatus": "CHARGING",
                    })
                    .then((_) {
                      if (mounted) setState(() => _isLoading = false);
                    });
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return PageScanQr(
      tabIndexNotifier: widget.tabIndexNotifier,
      ownTabIndex: widget.ownTabIndex,
    );
  }
}
