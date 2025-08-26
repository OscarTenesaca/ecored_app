import 'dart:convert';

import 'package:ecored_app/src/core/models/location_model.dart';

ModelStation modelStationFromJson(String str) =>
    ModelStation.fromJson(json.decode(str));

String modelStationToJson(ModelStation data) => json.encode(data.toJson());

class ModelStation {
  String id;
  String name;
  String address;
  String lat;
  String lng;
  Map<String, double> priceWithTipeConnector;
  List<Charger> chargers;
  String status;
  LocationModel? country;
  LocationModel? canton;

  ModelStation({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.priceWithTipeConnector,
    required this.chargers,
    required this.status,
    required this.country,
    required this.canton,
  });

  factory ModelStation.fromJson(Map<String, dynamic> json) => ModelStation(
    id: json["_id"] ?? '',
    name: json["name"] ?? '',
    address: json["address"] ?? '',
    lat: json["lat"] ?? '',
    lng: json["lng"] ?? '',
    priceWithTipeConnector: Map<String, double>.from(
      json["priceWithTipeConnector"],
    ),
    chargers: List<Charger>.from(
      json["chargers"].map((x) => Charger.fromJson(x)),
    ),
    canton:
        json["province"] != null
            ? LocationModel.fromJson(json["province"])
            : null,
    country:
        json["country"] != null
            ? LocationModel.fromJson(json["country"])
            : null,
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
    "lat": lat,
    "lng": lng,
    "priceWithTipeConnector": priceWithTipeConnector,
    "chargers": List<dynamic>.from(chargers.map((x) => x.toJson())),
    "status": status,
    "country": country,
    "canton": canton,
  };
}

class Charger {
  String id;
  String typeConnection;
  double powerKw;
  String status;
  String typeCharger;

  Charger({
    required this.id,
    required this.typeConnection,
    required this.powerKw,
    required this.status,
    required this.typeCharger,
  });

  factory Charger.fromJson(Map<String, dynamic> json) => Charger(
    id: json["_id"],
    typeConnection: json["typeConnection"],
    powerKw: json["powerKw"].toDouble(),
    status: json["status"],
    typeCharger: json["typeCharger"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "typeConnection": typeConnection,
    "powerKw": powerKw,
    "status": status,
    "typeCharger": typeCharger,
  };
}
