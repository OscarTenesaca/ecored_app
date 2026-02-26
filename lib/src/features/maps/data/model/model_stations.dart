import 'package:ecored_app/src/core/models/location_model.dart';

class ModelStation {
  final String id;
  final String name;
  final String address;
  final String prefixCode;
  final String phone;
  final String description;
  final String lat;
  final String lng;
  final String status;
  final String administrator;
  final LocationModel country;
  final DateTime createdAt;

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
    required this.administrator,
    required this.country,
    required this.createdAt,
  });

  factory ModelStation.fromJson(Map<String, dynamic> json) {
    final coordinates = json["location"]?["coordinates"];

    return ModelStation(
      id: json["_id"] ?? '',
      name: json["name"] ?? '',
      address: json["address"] ?? '',
      prefixCode: json["prefixCode"] ?? '',
      phone: json["phone"]?.toString() ?? '',
      description: json["description"] ?? '',
      lat:
          (coordinates != null && coordinates.length > 1)
              ? coordinates[1].toString()
              : '0',
      lng:
          (coordinates != null && coordinates.isNotEmpty)
              ? coordinates[0].toString()
              : '0',
      status: json["status"] ?? '',
      administrator: json["administrator"]?.toString() ?? '',
      country:
          json["country"] != null
              ? json["country"] is Map<String, dynamic>
                  ? LocationModel.fromJson(json["country"])
                  : LocationModel(
                    id: json["country"],
                    name: '',
                    code: '',
                    flag: '',
                  )
              : LocationModel(id: '', name: '', code: '', flag: ''),
      createdAt:
          json["createdAt"] != null
              ? DateTime.parse(json["createdAt"])
              : DateTime.now(),
    );
  }

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
    "administrator": administrator,
    "country": country.toJson(),
    "createdAt": createdAt.toIso8601String(),
  };
}
