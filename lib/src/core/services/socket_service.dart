import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Cliente Socket.IO para el namespace `/orders` del backend (gateway
/// `orders.gateway.ts`, ya existente — no se agregó ni modificó nada ahí).
///
/// Contrato del gateway (reutilizado tal cual):
/// - Namespace: `/orders` (NO lleva el prefijo `/api/v1`).
/// - Auth: JWT en `handshake.auth.token` (el mismo token del login REST).
/// - Cliente -> servidor: `subscribeToOrder` / `unsubscribeFromOrder`,
///   payload `{ orderId }`.
/// - Servidor -> cliente: `subscribed` (ack), `orderUpdate` (progreso de
///   la orden, hacia la room `order:<id>`), `error` ({ message }).
class SocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  /// Abre la conexión y se suscribe a la orden indicada. Si ya existe una
  /// conexión activa, no hace nada (idempotente).
  void connect(String orderId) {
    if (_socket != null) return;

    final String token = Preferences().getUser()?.token ?? '';

    final socket = io.io(
      '${Environment.url}/orders',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    _socket = socket;

    // 'connect' se dispara tanto en la conexión inicial como en cada
    // reconexión automática exitosa: re-suscribirse aquí cubre ambos
    // casos sin necesidad de lógica de reconexión manual.
    socket.onConnect((_) => socket.emit('subscribeToOrder', {'orderId': orderId}));
    socket.onReconnect((_) => socket.emit('subscribeToOrder', {'orderId': orderId}));

    socket.connect();
  }

  /// Escucha el progreso de la carga (evento `orderUpdate`). [onProgress]
  /// recibe el payload crudo del servidor para que quien lo use decida
  /// cómo fusionarlo con el estado que ya tiene.
  void listenChargeProgress(void Function(Map<String, dynamic> order) onProgress) {
    _socket?.on('orderUpdate', (data) {
      if (data is Map) onProgress(Map<String, dynamic>.from(data));
    });
  }

  /// Escucha errores del gateway (p. ej. token inválido, orden no
  /// encontrada, sin autorización sobre la orden).
  void listenErrors(void Function(String message) onError) {
    _socket?.on('error', (data) {
      final message =
          (data is Map ? data['message']?.toString() : null) ??
          'Error de conexión con el servidor';
      onError(message);
    });
  }

  /// Se desuscribe de la orden, quita todos los listeners y cierra la
  /// conexión. Seguro de llamar aunque ya esté desconectado.
  void disconnect(String orderId) {
    final socket = _socket;
    if (socket == null) return;

    if (socket.connected) {
      socket.emit('unsubscribeFromOrder', {'orderId': orderId});
    }
    socket.clearListeners();
    socket.disconnect();
    socket.dispose();
    _socket = null;
  }
}
