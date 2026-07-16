import 'dart:convert';

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
  String format;
  String status;
  String typeCharger;
  double priceWithTipeConnector;
  ModelStation? station;

  ModelCharger({
    this.id,
    required this.code,
    required this.typeConnection,
    required this.connectorId,
    required this.powerKw,
    required this.intensity,
    required this.voltage,
    required this.format,
    required this.status,
    required this.typeCharger,
    required this.priceWithTipeConnector,
    this.station,
  });

  factory ModelCharger.fromJson(Map<String, dynamic> json) => ModelCharger(
    id: json["_id"],
    code: json["code"] ?? '',
    typeConnection: json["typeConnection"] ?? '',
    connectorId: json["connectorId"]?.toInt() ?? 0,
    powerKw: json["powerKw"]?.toDouble() ?? 0,
    intensity: json["intensity"]?.toDouble() ?? 0,
    voltage: json["voltage"]?.toDouble() ?? 0,
    format: json["format"] ?? '',
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
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "code": code,
    "typeConnection": typeConnection,
    "connectorId": connectorId,
    "powerKw": powerKw,
    "intensity": intensity,
    "voltage": voltage,
    "format": format,
    "status": status,
    "typeCharger": typeCharger,
    "priceWithTipeConnector": priceWithTipeConnector,
    "station": station?.toJson(),
  };
}
