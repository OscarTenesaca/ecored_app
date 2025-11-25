// To parse this JSON data, do
//
//     final modelRecharge = modelRechargeFromJson(jsonString);

import 'dart:convert';

ModelRecharge modelRechargeFromJson(String str) =>
    ModelRecharge.fromJson(json.decode(str));

String modelRechargeToJson(ModelRecharge data) => json.encode(data.toJson());

class ModelRecharge {
  String id;
  String statusCreated;
  String status;
  int value;
  String devReference;
  String authorizationCode;
  String transactionId;
  String user;
  Payments payment;
  String createdAt;

  ModelRecharge({
    required this.id,
    required this.statusCreated,
    required this.status,
    required this.value,
    required this.devReference,
    required this.authorizationCode,
    required this.transactionId,
    required this.user,
    required this.payment,
    required this.createdAt,
  });

  factory ModelRecharge.fromJson(Map<String, dynamic> json) => ModelRecharge(
    id: json["_id"],
    statusCreated: json["statusCreated"],
    status: json["status"],
    value: json["value"],
    devReference: json["devReference"],
    authorizationCode: json["authorizationCode"],
    transactionId: json["transactionId"],
    user: json["user"],
    payment: Payments.fromJson(json["payment"]),
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "statusCreated": statusCreated,
    "status": status,
    "value": value,
    "devReference": devReference,
    "authorizationCode": authorizationCode,
    "transactionId": transactionId,
    "user": user,
    "payment": payment.toJson(),
    "createdAt": createdAt,
  };
}

class Payments {
  String id;
  String name;

  Payments({required this.id, required this.name});

  factory Payments.fromJson(Map<String, dynamic> json) =>
      Payments(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}
