class ModelConnectorType {
  String id;
  String code;
  String name;
  String icon;

  ModelConnectorType({
    required this.id,
    required this.code,
    required this.name,
    required this.icon,
  });

  factory ModelConnectorType.fromJson(Map<String, dynamic> json) =>
      ModelConnectorType(
        id: json["_id"] ?? '',
        code: json["code"] ?? '',
        name: json["name"] ?? '',
        icon: json["icon"] ?? '',
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "code": code,
    "name": name,
    "icon": icon,
  };
}
