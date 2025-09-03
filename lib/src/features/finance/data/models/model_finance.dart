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
  int total;
  int totalRecharges;
  int totalSpent;
  DateTime startDate;
  DateTime endDate;
  int accumulated;
  String country;
  String canton;
  String user;
  List<String> transactions;
  DateTime createdAt;

  ModelFinance({
    required this.id,
    required this.status,
    required this.currency,
    required this.total,
    required this.totalRecharges,
    required this.totalSpent,
    required this.startDate,
    required this.endDate,
    required this.accumulated,
    required this.country,
    required this.canton,
    required this.user,
    required this.transactions,
    required this.createdAt,
  });

  factory ModelFinance.fromJson(Map<String, dynamic> json) => ModelFinance(
    id: json["_id"] ?? '',
    status: json["status"] ?? '',
    currency: json["currency"] ?? '',
    total: json["total"] ?? '',
    totalRecharges: json["totalRecharges"] ?? '',
    totalSpent: json["totalSpent"] ?? '',
    startDate: DateTime.parse(json["startDate"]),
    endDate: DateTime.parse(json["endDate"]),
    accumulated: json["accumulated"] ?? '',
    country: json["country"] ?? '',
    canton: json["canton"] ?? '',
    user: json["user"] ?? '',
    transactions: List<String>.from(json["transactions"].map((x) => x)) ?? [],
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "status": status,
    "currency": currency,
    "total": total,
    "totalRecharges": totalRecharges,
    "totalSpent": totalSpent,
    "startDate": startDate.toIso8601String(),
    "endDate": endDate.toIso8601String(),
    "accumulated": accumulated,
    "country": country,
    "canton": canton,
    "user": user,
    "transactions": List<dynamic>.from(transactions.map((x) => x)),
    "createdAt": createdAt.toIso8601String(),
  };
}
