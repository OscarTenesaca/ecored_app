class LocationModel {
  String id;
  String name;
  String flag;
  String code;

  LocationModel({
    required this.id,
    required this.name,
    required this.flag,
    required this.code,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    id: json["_id"],
    name: json["name"],
    flag: json["flag"] ?? '',
    code: json["code"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "flag": flag,
    "code": code,
  };
}
