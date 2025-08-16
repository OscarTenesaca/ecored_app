class LocationModel {
  String id;
  String name;

  LocationModel({required this.id, required this.name});

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      LocationModel(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}
