import 'package:ecored_app/src/features/maps/data/model/model_charger.dart';

/// Unidad física de carga (hardware) — agrupa uno o más conectores
/// ([ModelCharger]) del endpoint `GET /station/preview/:id`.
class ModelChargePoint {
  String id;
  String code;
  String? station;
  String? administrator;
  String? connectionStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<ModelCharger> connectors;

  ModelChargePoint({
    required this.id,
    required this.code,
    this.station,
    this.administrator,
    this.connectionStatus,
    this.createdAt,
    this.updatedAt,
    required this.connectors,
  });

  factory ModelChargePoint.fromJson(
    Map<String, dynamic> json,
  ) => ModelChargePoint(
    id: json["_id"] ?? '',
    code: json["code"] ?? '',
    station: json["station"]?.toString(),
    administrator: json["administrator"]?.toString(),
    connectionStatus: json["connectionStatus"],
    createdAt:
        json["createdAt"] != null ? DateTime.tryParse(json["createdAt"]) : null,
    updatedAt:
        json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) : null,
    connectors:
        (json["connectors"] as List? ?? [])
            .map((c) => ModelCharger.fromJson(c))
            .toList(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "code": code,
    "station": station,
    "administrator": administrator,
    "connectionStatus": connectionStatus,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "connectors": connectors.map((c) => c.toJson()).toList(),
  };
}
