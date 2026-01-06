// To parse this JSON data, do
//
//     final modelNuvei = modelNuveiFromJson(jsonString);

import 'dart:convert';

ModelNuvei modelNuveiFromJson(String str) =>
    ModelNuvei.fromJson(json.decode(str));

String modelNuveiToJson(ModelNuvei data) => json.encode(data.toJson());

class ModelNuvei {
  String userId;
  String email;
  String description;
  double amount;
  double vat;
  String devReference;

  ModelNuvei({
    required this.userId,
    required this.email,
    required this.description,
    required this.amount,
    required this.vat,
    required this.devReference,
  });

  factory ModelNuvei.fromJson(Map<String, dynamic> json) => ModelNuvei(
    userId: json["userId"],
    email: json["email"],
    description: json["description"],
    amount: json["amount"],
    vat: json["vat"],
    devReference: json["dev_reference"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "email": email,
    "description": description,
    "amount": amount,
    "vat": vat,
    "dev_reference": devReference,
  };
}
