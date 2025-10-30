import 'dart:convert';

import 'package:ecored_app/src/core/models/location_model.dart';

ModelStation modelStationFromJson(String str) =>
    ModelStation.fromJson(json.decode(str));

String modelStationToJson(ModelStation data) => json.encode(data.toJson());

class ModelStation {
  String id;
  String name;
  String address;
  String prefixCode;
  String phone;
  String description;
  String lat;
  String lng;
  String status;
  String administrator;
  DateTime createdAt;
  String? province;
  // LocationModel? country;
  // LocationModel? canton;

  ModelStation({
    required this.id,
    required this.name,
    required this.address,
    required this.prefixCode,
    required this.phone,
    required this.description,
    required this.lat,
    required this.lng,
    required this.status,
    // required this.country,
    // required this.province,
    // required this.canton,
    required this.administrator,
    required this.createdAt,
  });

  factory ModelStation.fromJson(Map<String, dynamic> json) => ModelStation(
    id: json["_id"],
    name: json["name"],
    address: json["address"],
    prefixCode: json["prefixCode"],
    phone: json["phone"],
    description: json["description"],
    lat: json["lat"],
    lng: json["lng"],
    status: json["status"],
    administrator: json["administrator"],
    createdAt: DateTime.parse(json["createdAt"]),
    // province: json["province"],
    // canton:
    //     json["province"] != null
    //         ? LocationModel.fromJson(json["province"])
    //         : null,
    // country:
    //     json["country"] != null
    //         ? LocationModel.fromJson(json["country"])
    //         : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
    "prefixCode": prefixCode,
    "phone": phone,
    "description": description,
    "lat": lat,
    "lng": lng,
    "status": status,
    // "country": country?.toJson(),
    // "province": province,
    // "canton": canton?.toJson(),
    "administrator": administrator,
    "createdAt": createdAt.toIso8601String(),
  };
}
