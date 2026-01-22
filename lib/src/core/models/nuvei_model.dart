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
  String? phone;
  String description;
  double amount;
  double vat;
  String devReference;

  ModelNuvei({
    required this.userId,
    required this.email,
    this.phone,
    required this.description,
    required this.amount,
    required this.vat,
    required this.devReference,
  });

  factory ModelNuvei.fromJson(Map<String, dynamic> json) => ModelNuvei(
    userId: json["userId"],
    email: json["email"],
    phone: json["phone"],
    description: json["description"],
    amount: json["amount"],
    vat: json["vat"],
    devReference: json["dev_reference"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "email": email,
    "phone": phone,
    "description": description,
    "amount": amount,
    "vat": vat,
    "dev_reference": devReference,
  };
}
