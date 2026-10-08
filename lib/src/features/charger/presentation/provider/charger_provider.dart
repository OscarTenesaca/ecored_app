import 'dart:developer';

import 'package:ecored_app/src/core/services/socket_service.dart';
import 'package:ecored_app/src/features/charger/domain/usecase/charger_services.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:flutter/material.dart';

// Estados terminales de OperationStatus (backend: src/common/constants) —
// al llegar cualquiera de estos por socket, la carga ya no está activa.
const List<String> _terminalOperationStatuses = ['FINISHED', 'FAILED', 'CANCELLED'];

class ChargerProvider extends ChangeNotifier {
  final ChargerServices services;
  final SocketService _socketService = SocketService();

  ModelOrder? orderData;
  bool isLoading = false;
  String? errorMessage;

  ChargerProvider(this.services);

  Future<void> getOrderData(Map<String, dynamic> params) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // orderData en null significa que el usuario no tiene ninguna
      // carga activa (estado normal, no un error de red/servidor).
      orderData = await services.getOrderData(params);

      notifyListeners();

      // Hay una orden activa: conectar el socket para recibir su
      // progreso en tiempo real (si ya estaba conectado, no hace nada).
      if (orderData != null) {
        connectChargeSocket();
      }
    } catch (e) {
      errorMessage = e.toString();
      orderData = null;
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<int> deleteStopCharger(Map<String, dynamic> params) async {
    try {
      final stopData = await services.deleteStopCharger(params);
      return stopData;
    } catch (e) {
      return -1;
    }
  }

  /// Se conecta al socket de la orden activa y escucha su progreso en
  /// tiempo real (evento `orderUpdate` del gateway `orders.gateway.ts`).
  /// No hace nada si no hay una orden activa o si ya se inició una
  /// conexión.
  ///
  /// Se llama desde 2 lugares (`getOrderData()` acá abajo, y
  /// `PageCharger.initState()`) que pueden disparar casi al mismo tiempo:
  /// el primero fija `orderData` y llama esto; el segundo se monta apenas
  /// `PageOptCharger` reacciona a ese cambio, en el siguiente frame. El
  /// guard usaba `isConnected` (el handshake del WebSocket, que tarda) en
  /// vez de "¿ya inicié una conexión?" — dejaba una ventana en la que la
  /// segunda llamada pasaba el guard igual y volvía a registrar los
  /// `listen*`, duplicando los listeners de `orderUpdate`/`orderClosed`.
  /// `isActive` (¿ya existe el socket, conectado o no?) cierra esa ventana.
  void connectChargeSocket() {
    final order = orderData;
    if (order == null || _socketService.isActive) {
      log(
        '⏭️ connectChargeSocket() ignorado: '
        'order=${order?.id} isActive=${_socketService.isActive}',
        name: 'ChargerProvider',
      );
      return;
    }

    log('🔌 connectChargeSocket() → orderId=${order.id}', name: 'ChargerProvider');
    _socketService.connect(order.id);

    // `orderUpdate` llega mientras la orden sigue activa; `orderClosed` es
    // el mensaje final que el gateway manda en su lugar apenas la orden
    // llega a un operationStatus terminal — mismo payload, así que ambos
    // se procesan igual.
    _socketService.listenChargeProgress(_applyOrderPayload);
    _socketService.listenOrderClosed(_applyOrderPayload);

    _socketService.listenErrors((message) {
      errorMessage = message;
      notifyListeners();
    });
  }

  void _applyOrderPayload(Map<String, dynamic> json) {
    log('📡 socket orderUpdate/orderClosed ← $json', name: 'ChargerProvider');

    final current = orderData;
    if (current == null) {
      log(
        '⚠️ socket: llegó data pero orderData ya era null, se ignora',
        name: 'ChargerProvider',
      );
      return;
    }

    orderData = current.applyProgress(json);
    log(
      '📡 socket → orderData actualizado: '
      'total=${orderData!.total} subtotal=${orderData!.subtotal} '
      'kWhDelivered=${orderData!.kWhDelivered} '
      'currentPowerKw=${orderData!.currentPowerKw} '
      'soc=${orderData!.soc} operationStatus=${orderData!.operationStatus}',
      name: 'ChargerProvider',
    );
    notifyListeners();

    // La carga terminó (finalizada, fallida o cancelada): ya no hace
    // falta seguir escuchando, se cierra la conexión automáticamente.
    if (_terminalOperationStatuses.contains(orderData!.operationStatus)) {
      disconnectChargeSocket();
    }
  }

  /// Cierra la conexión del socket y se desuscribe de la orden. Segura
  /// de llamar aunque no haya ninguna conexión activa.
  void disconnectChargeSocket() {
    final orderId = orderData?.id;
    if (orderId == null) return;
    _socketService.disconnect(orderId);
  }

  /// Limpia la orden activa (p. ej. tras confirmarse que la carga
  /// terminó y esperar el margen de cortesía en la UI). Al quedar en
  /// `null`, `PageOptCharger` vuelve a mostrar `PageScanQr` de forma
  /// automática, sin necesidad de una navegación explícita.
  void clearOrderData() {
    orderData = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnectChargeSocket();
    super.dispose();
  }
}
