// To parse this JSON data, do
//
//     final paymentModel = paymentModelFromJson(jsonString);

import 'dart:convert';

PaymentModel paymentModelFromJson(String str) =>
    PaymentModel.fromJson(json.decode(str));

String paymentModelToJson(PaymentModel data) => json.encode(data.toJson());

class PaymentModel {
  String id;
  bool isPrivate;
  String status;
  String name;
  int comission;
  String img;

  PaymentModel({
    required this.id,
    required this.isPrivate,
    required this.status,
    required this.name,
    required this.comission,
    required this.img,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json["_id"],
    isPrivate: json["isPrivate"],
    status: json["status"],
    name: json["name"],
    comission: json["comission"],
    img: json["img"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "isPrivate": isPrivate,
    "status": status,
    "name": name,
    "comission": comission,
    "img": img,
  };
}
