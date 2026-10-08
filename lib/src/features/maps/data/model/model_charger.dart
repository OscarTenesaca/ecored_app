import 'dart:convert';

import 'package:ecored_app/src/features/maps/data/model/model_connector_type.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';

ModelCharger modelChargerFromJson(String str) =>
    ModelCharger.fromJson(json.decode(str));

String modelChargerToJson(ModelCharger data) => json.encode(data.toJson());

class ModelCharger {
  String? id;
  String code;
  String typeConnection;
  int connectorId;
  double powerKw;
  double intensity;
  double voltage;
  String status;
  String typeCharger;
  double priceWithTipeConnector;
  ModelStation? station;
  // Último status de StatusNotification OCPP para este conector puntual
  // (Available/Preparing/Charging/Faulted/...) — distinto de `status`, que
  // es el estado administrativo del charger (AVAILABLE/MAINTENANCE/...).
  String? connectorStatus;
  // Estado de la conexión WebSocket del charge point con el backend
  // (CONNECTED/DISCONNECTED) — indica si la estación está "en línea".
  String? connectionStatus;
  // Código de error OCPP del último StatusNotification (NoError, ...).
  String? connectorErrorCode;
  // Fecha del último StatusNotification recibido para este conector.
  DateTime? lastStatusNotificationAt;
  // Fecha del último Heartbeat OCPP recibido del charge point.
  DateTime? lastHeartbeatAt;
  // Administrador dueño de este charger puntual (ObjectId como string).
  String? administrator;
  // ChargePoint OCPP al que pertenece este conector (ObjectId como string).
  String? chargePoint;
  // Orden activa que está ocupando este conector, si hay una (ObjectId).
  String? currentOrder;
  DateTime? createdAt;
  DateTime? updatedAt;
  // Etiqueta corta para mostrar en UI (ej. "A", "B") — nunca participa en OCPP.
  String? displayLabel;
  // Catálogo del tipo de conector (nombre/ícono), poblado por el backend.
  ModelConnectorType? connectorType;

  ModelCharger({
    this.id,
    required this.code,
    required this.typeConnection,
    required this.connectorId,
    required this.powerKw,
    required this.intensity,
    required this.voltage,
    required this.status,
    required this.typeCharger,
    required this.priceWithTipeConnector,
    this.station,
    this.connectorStatus,
    this.connectionStatus,
    this.connectorErrorCode,
    this.lastStatusNotificationAt,
    this.lastHeartbeatAt,
    this.administrator,
    this.chargePoint,
    this.currentOrder,
    this.createdAt,
    this.updatedAt,
    this.displayLabel,
    this.connectorType,
  });

  factory ModelCharger.fromJson(Map<String, dynamic> json) => ModelCharger(
    id: json["_id"],
    code: json["code"] ?? '',
    typeConnection: json["typeConnection"] ?? '',
    connectorId: json["connectorId"]?.toInt() ?? 0,
    powerKw: json["powerKw"]?.toDouble() ?? 0,
    intensity: json["intensity"]?.toDouble() ?? 0,
    voltage: json["voltage"]?.toDouble() ?? 0,
    status: json["status"] ?? '',
    typeCharger: json["typeCharger"] ?? '',
    priceWithTipeConnector: json["priceWithTipeConnector"]?.toDouble() ?? 0,
    station:
        json["station"] == null
            ? null
            : json["station"] is String
            ? null
            : ModelStation.fromJson(json["station"]),
    // station:
    //     json["station"] == null ? null : ModelStation.fromJson(json["station"]),
    connectorStatus: json["connectorStatus"],
    connectionStatus: json["connectionStatus"],
    connectorErrorCode: json["connectorErrorCode"],
    lastStatusNotificationAt:
        json["lastStatusNotificationAt"] != null
            ? DateTime.tryParse(json["lastStatusNotificationAt"])
            : null,
    lastHeartbeatAt:
        json["lastHeartbeatAt"] != null
            ? DateTime.tryParse(json["lastHeartbeatAt"])
            : null,
    administrator: json["administrator"]?.toString(),
    chargePoint: json["chargePoint"]?.toString(),
    currentOrder: json["currentOrder"]?.toString(),
    createdAt:
        json["createdAt"] != null ? DateTime.tryParse(json["createdAt"]) : null,
    updatedAt:
        json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) : null,
    displayLabel: json["displayLabel"],
    connectorType:
        json["connectorType"] is Map<String, dynamic>
            ? ModelConnectorType.fromJson(json["connectorType"])
            : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "code": code,
    "typeConnection": typeConnection,
    "connectorId": connectorId,
    "powerKw": powerKw,
    "intensity": intensity,
    "voltage": voltage,
    "status": status,
    "typeCharger": typeCharger,
    "priceWithTipeConnector": priceWithTipeConnector,
    "station": station?.toJson(),
    "connectorStatus": connectorStatus,
    "connectionStatus": connectionStatus,
    "connectorErrorCode": connectorErrorCode,
    "lastStatusNotificationAt": lastStatusNotificationAt?.toIso8601String(),
    "lastHeartbeatAt": lastHeartbeatAt?.toIso8601String(),
    "administrator": administrator,
    "chargePoint": chargePoint,
    "currentOrder": currentOrder,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "displayLabel": displayLabel,
    "connectorType": connectorType?.toJson(),
  };
}
