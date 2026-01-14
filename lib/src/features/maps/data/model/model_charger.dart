import 'dart:convert';

ModelCharger modelChargerFromJson(String str) =>
    ModelCharger.fromJson(json.decode(str));

String modelChargerToJson(ModelCharger data) => json.encode(data.toJson());

class ModelCharger {
  String? id;
  String typeConnection;
  int powerKw;
  String status;
  String typeCharger;
  double priceWithTipeConnector;

  ModelCharger({
    this.id,
    required this.typeConnection,
    required this.powerKw,
    required this.status,
    required this.typeCharger,
    required this.priceWithTipeConnector,
  });

  factory ModelCharger.fromJson(Map<String, dynamic> json) => ModelCharger(
    id: json["_id"],
    typeConnection: json["typeConnection"],
    powerKw: json["powerKw"],
    status: json["status"],
    typeCharger: json["typeCharger"],
    priceWithTipeConnector: json["priceWithTipeConnector"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "typeConnection": typeConnection,
    "powerKw": powerKw,
    "status": status,
    "typeCharger": typeCharger,
    "priceWithTipeConnector": priceWithTipeConnector,
  };
}
