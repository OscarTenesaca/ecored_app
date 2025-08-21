// To parse this JSON data, do
//
//     final modelUser = modelUserFromJson(jsonString);

//? CLASE ONE

import 'dart:convert';

import 'package:ecored_app/src/core/models/location_model.dart';

ModelUser modelUserFromJson(String str) => ModelUser.fromJson(json.decode(str));

String modelUserToJson(ModelUser data) => json.encode(data.toJson());

class ModelUser {
  String id;
  String img;
  String ci;
  String name;
  String email;
  String prefix;
  String phone;
  String status;
  DateTime birthdate;
  LocationModel? province;
  LocationModel? country;
  String token;

  ModelUser({
    required this.id,
    required this.img,
    required this.ci,
    required this.name,
    required this.email,
    required this.prefix,
    required this.phone,
    required this.status,
    required this.birthdate,
    required this.province,
    required this.country,
    required this.token,
  });

  factory ModelUser.fromJson(Map<String, dynamic> json) => ModelUser(
    id: json["_id"] ?? '',
    img: json["img"] ?? '',
    ci: json["ci"] ?? '',
    name: json["name"] ?? '',
    email: json["email"] ?? '',
    prefix: json["prefix"] ?? '',
    phone: json["phone"] ?? '',
    status: json["status"] ?? '',
    birthdate: DateTime.parse(json["birthdate"]),
    token: json["token"] ?? '',
    province:
        json["province"] != null
            ? LocationModel.fromJson(json["province"])
            : null,
    country:
        json["country"] != null
            ? LocationModel.fromJson(json["country"])
            : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "img": img,
    "ci": ci,
    "name": name,
    "email": email,
    "prefix": prefix,
    "phone": phone,
    "status": status,
    "birthdate": birthdate.toIso8601String(),
    "province": province,
    "country": country,
    "token": token,
  };
}
