// To parse this JSON data, do
//
//     final modelTransaction = modelTransactionFromJson(jsonString);

import 'dart:convert';

ModelTransaction modelTransactionFromJson(String str) =>
    ModelTransaction.fromJson(json.decode(str));

String modelTransactionToJson(ModelTransaction data) =>
    json.encode(data.toJson());

class ModelTransaction {
  String id;
  String statusCreated;
  String status;
  int value;
  String devReference;
  String authorizationCode;
  String transactionId;
  String user;
  dynamic payment;
  String createdAt;
  DateTime updatedAt;

  ModelTransaction({
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
    required this.updatedAt,
  });

  factory ModelTransaction.fromJson(Map<String, dynamic> json) =>
      ModelTransaction(
        id: json["_id"],
        statusCreated: json["statusCreated"],
        status: json["status"],
        value: json["value"],
        devReference: json["devReference"],
        authorizationCode: json["authorizationCode"],
        transactionId: json["transactionId"],
        user: json["user"],
        payment: json["payment"],
        createdAt: json["createdAt"],
        updatedAt: DateTime.parse(json["updatedAt"]),
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
    "payment": payment,
    "createdAt": createdAt,
    "updatedAt": updatedAt.toIso8601String(),
  };
}
