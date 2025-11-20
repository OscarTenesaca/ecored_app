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
  String type;
  double amount;
  String description;
  String user;
  String? order;
  String? recharge;
  String wallet;
  DateTime createdAt;

  ModelTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.user,
    required this.order,
    required this.recharge,
    required this.wallet,
    required this.createdAt,
  });

  factory ModelTransaction.fromJson(Map<String, dynamic> json) =>
      ModelTransaction(
        id: json["_id"] ?? '',
        type: json["type"] ?? '',
        amount: json["amount"]?.toDouble(),
        description: json["description"] ?? '',
        user: json["user"] ?? '',
        order: json["order"],
        recharge: json["recharge"],
        wallet: json["wallet"] ?? '',
        createdAt: DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": type,
    "amount": amount,
    "description": description,
    "user": user,
    "order": order,
    "recharge": recharge,
    "wallet": wallet,
    "createdAt": createdAt.toIso8601String(),
  };
}
