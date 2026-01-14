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
    required this.createdAt,
  });

  factory ModelStation.fromJson(Map<String, dynamic> json) => ModelStation(
    id: json["_id"] ?? '',
    name: json["name"] ?? '',
    address: json["address"] ?? '',
    prefixCode: json["prefixCode"] ?? '',
    phone: json["phone"] ?? '',
    description: json["description"] ?? '',
    lat: json["location"]["coordinates"][1]?.toString() ?? '0',
    lng: json["location"]["coordinates"][0]?.toString() ?? '0',
    status: json["status"] ?? '',
    administrator: json["administrator"] ?? '',
    createdAt:
        json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : DateTime.now(),
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
    "administrator": administrator,
    "createdAt": createdAt.toIso8601String(),
  };
}
