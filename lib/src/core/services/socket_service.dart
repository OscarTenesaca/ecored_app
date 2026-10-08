import 'dart:developer';

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
///   la orden, hacia la room `order:<id>`), `orderClosed` (mismo payload
///   que `orderUpdate`, pero cuando la orden ya llegó a un operationStatus
///   terminal — reemplaza a `orderUpdate` para ese último mensaje y el
///   servidor saca a todos los sockets de la room después), `error`
///   ({ message }).
class SocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  /// True desde que se llamó `connect()` una vez, aunque el handshake
  /// todavía no haya terminado (a diferencia de `isConnected`, que recién
  /// es true cuando el WebSocket ya está establecido). Sirve para que
  /// quien orqueste la conexión (`ChargerProvider`) sepa que ya inició
  /// una conexión y no debe volver a registrar listeners — `connect()`
  /// puede tardar en completar el handshake, y en ese lapso `isConnected`
  /// sigue en false aunque ya no haga falta (ni sea seguro) llamar de
  /// nuevo a los `listen*`.
  bool get isActive => _socket != null;

  /// Abre la conexión y se suscribe a la orden indicada. Si ya existe una
  /// conexión activa, no hace nada (idempotente).
  void connect(String orderId) {
    if (_socket != null) {
      log('⏭️ connect() ignorado: ya existe un socket activo', name: 'SocketService');
      return;
    }

    final String token = Preferences().getUser()?.token ?? '';
    log(
      '🔌 connect() → ${Environment.url}/orders '
      'orderId=$orderId tokenPresente=${token.isNotEmpty}',
      name: 'SocketService',
    );

    final socket = io.io(
      '${Environment.url}/orders',
      io.OptionBuilder()
          // Probado sin forzar transporte (dejando que arranque por
          // polling, como hace Socket.IO por defecto): el resultado fue
          // peor — ni siquiera lograba conectar (`connect_error: timeout`).
          // O sea que el polling HTTP no llega a completar el handshake
          // contra este servidor/red en particular, mientras que WebSocket
          // directo sí conecta (aunque después se corte). Se vuelve a
          // forzar 'websocket' porque es la única opción que efectivamente
          // logra conectar acá.
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );
    _socket = socket;

    void subscribe() {
      log('📤 emit subscribeToOrder orderId=$orderId', name: 'SocketService');
      socket.emit('subscribeToOrder', {'orderId': orderId});
    }

    // 'connect' se dispara tanto en la conexión inicial como en cada
    // reconexión automática exitosa: re-suscribirse aquí cubre ambos
    // casos sin necesidad de lógica de reconexión manual.
    socket.onConnect((_) {
      log('✅ socket conectado (handshake OK)', name: 'SocketService');
      subscribe();
    });
    socket.onReconnect((_) {
      log('🔁 socket reconectado', name: 'SocketService');
      subscribe();
    });
    socket.on('subscribed', (data) {
      log('✅ ack subscribed ← $data', name: 'SocketService');
    });
    socket.onConnectError((data) {
      log('❌ connect_error: $data', name: 'SocketService');
    });
    socket.onDisconnect((reason) {
      log('🔌 desconectado: $reason', name: 'SocketService');
    });
    // Captura CUALQUIER evento que llegue por este socket, sin importar el
    // nombre — si 'orderUpdate'/'orderClosed' nunca imprimen nada más abajo
    // pero esto sí muestra algo, es un evento con otro nombre. Si esto
    // tampoco imprime nunca, el servidor genuinamente no está mandando nada
    // por este socket después del ack de 'subscribed'.
    socket.onAny((event, data) {
      log('📥 onAny event="$event" data=$data', name: 'SocketService');
    });

    socket.connect();
  }

  /// Normaliza el payload crudo que entrega `.on()`. Cuando el paquete de
  /// Socket.IO trae un `id` de acknowledgement adjunto (visible en los
  /// logs de `onAny` como un segundo valor tipo "Q3hLFE0" al final del
  /// array), `socket_io_client` entrega el callback con una `List` de 2
  /// elementos (`[payload, ackFn]`) en vez del `Map` directo — confirmado
  /// leyendo `emitEvent()` en el propio paquete (`socket.dart`, se activa
  /// cuando `args.length > 2`). Sin este desempaquetado, un chequeo
  /// `data is Map` falla en silencio y el payload real nunca se procesa,
  /// aunque el evento sí haya llegado (visible por `onAny` pero no por el
  /// listener específico).
  Map<String, dynamic>? _unwrapPayload(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    return null;
  }

  /// Escucha el progreso de la carga (evento `orderUpdate`). [onProgress]
  /// recibe el payload crudo del servidor para que quien lo use decida
  /// cómo fusionarlo con el estado que ya tiene.
  void listenChargeProgress(void Function(Map<String, dynamic> order) onProgress) {
    _socket?.on('orderUpdate', (data) {
      final payload = _unwrapPayload(data);
      if (payload != null) onProgress(payload);
    });
  }

  /// Escucha el cierre de la orden (evento `orderClosed`) — el mensaje
  /// final que manda el gateway cuando la orden llega a un operationStatus
  /// terminal, en vez de un `orderUpdate` más. Sin este listener, quien use
  /// el servicio nunca se entera de que la carga terminó por esta vía.
  void listenOrderClosed(void Function(Map<String, dynamic> order) onClosed) {
    _socket?.on('orderClosed', (data) {
      final payload = _unwrapPayload(data);
      if (payload != null) onClosed(payload);
    });
  }

  /// Escucha errores del gateway (p. ej. token inválido, orden no
  /// encontrada, sin autorización sobre la orden).
  void listenErrors(void Function(String message) onError) {
    _socket?.on('error', (data) {
      final payload = _unwrapPayload(data);
      final message =
          payload?['message']?.toString() ?? 'Error de conexión con el servidor';
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
