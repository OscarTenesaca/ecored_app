// To parse this JSON data, do
//
//     final modelFinance = modelFinanceFromJson(jsonString);

import 'dart:convert';

ModelFinance modelFinanceFromJson(String str) =>
    ModelFinance.fromJson(json.decode(str));

String modelFinanceToJson(ModelFinance data) => json.encode(data.toJson());

class ModelFinance {
  String id;
  String status;
  String currency;
  int balance;
  String user;
  DateTime createdAt;

  ModelFinance({
    required this.id,
    required this.status,
    required this.currency,
    required this.balance,
    required this.user,
    required this.createdAt,
  });

  factory ModelFinance.fromJson(Map<String, dynamic> json) => ModelFinance(
    id: json["_id"],
    status: json["status"],
    currency: json["currency"],
    balance: json["balance"],
    user: json["user"],
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "status": status,
    "currency": currency,
    "balance": balance,
    "user": user,
    "createdAt": createdAt.toIso8601String(),
  };
}
