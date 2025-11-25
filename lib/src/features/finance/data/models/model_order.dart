// To parse this JSON data, do
//
//     final modelOrder = modelOrderFromJson(jsonString);

import 'dart:convert';

ModelOrder modelOrderFromJson(String str) =>
    ModelOrder.fromJson(json.decode(str));

String modelOrderToJson(ModelOrder data) => json.encode(data.toJson());

class ModelOrder {
  String id;
  String platformBuy;
  String status;
  int kWhCharged;
  double tax;
  int subtotal;
  double total;
  int discount;
  int discountTotal;
  User user;
  Stations stations;
  Charger charger;
  String recharge;
  Payment payment;
  Country country;
  String createdAt;

  ModelOrder({
    required this.id,
    required this.platformBuy,
    required this.status,
    required this.kWhCharged,
    required this.tax,
    required this.subtotal,
    required this.total,
    required this.discount,
    required this.discountTotal,
    required this.user,
    required this.stations,
    required this.charger,
    required this.recharge,
    required this.payment,
    required this.country,
    required this.createdAt,
  });

  factory ModelOrder.fromJson(Map<String, dynamic> json) => ModelOrder(
    id: json["_id"],
    platformBuy: json["platformBuy"],
    status: json["status"],
    kWhCharged: json["kWhCharged"],
    tax: json["tax"]?.toDouble(),
    subtotal: json["subtotal"],
    total: json["total"]?.toDouble(),
    discount: json["discount"],
    discountTotal: json["discountTotal"],
    user: User.fromJson(json["user"]),
    stations: Stations.fromJson(json["stations"]),
    charger: Charger.fromJson(json["charger"]),
    recharge: json["recharge"],
    payment: Payment.fromJson(json["payment"]),
    country: Country.fromJson(json["country"]),
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "platformBuy": platformBuy,
    "status": status,
    "kWhCharged": kWhCharged,
    "tax": tax,
    "subtotal": subtotal,
    "total": total,
    "discount": discount,
    "discountTotal": discountTotal,
    "user": user.toJson(),
    "stations": stations.toJson(),
    "charger": charger.toJson(),
    "recharge": recharge,
    "payment": payment.toJson(),
    "country": country.toJson(),
    "createdAt": createdAt,
  };
}

class Charger {
  String id;
  String typeConnection;

  Charger({required this.id, required this.typeConnection});

  factory Charger.fromJson(Map<String, dynamic> json) =>
      Charger(id: json["_id"], typeConnection: json["typeConnection"]);

  Map<String, dynamic> toJson() => {
    "_id": id,
    "typeConnection": typeConnection,
  };
}

class Country {
  String id;
  String name;
  String code;

  Country({required this.id, required this.name, required this.code});

  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(id: json["_id"], name: json["name"], code: json["code"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "code": code};
}

class Payment {
  String id;
  String name;

  Payment({required this.id, required this.name});

  factory Payment.fromJson(Map<String, dynamic> json) =>
      Payment(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class Stations {
  String id;
  String name;
  String address;
  String prefixCode;
  String phone;

  Stations({
    required this.id,
    required this.name,
    required this.address,
    required this.prefixCode,
    required this.phone,
  });

  factory Stations.fromJson(Map<String, dynamic> json) => Stations(
    id: json["_id"],
    name: json["name"],
    address: json["address"],
    prefixCode: json["prefixCode"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
    "prefixCode": prefixCode,
    "phone": phone,
  };
}

class User {
  String id;
  String ci;
  String name;
  String email;
  String prefix;
  String phone;

  User({
    required this.id,
    required this.ci,
    required this.name,
    required this.email,
    required this.prefix,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    ci: json["ci"],
    name: json["name"],
    email: json["email"],
    prefix: json["prefix"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ci": ci,
    "name": name,
    "email": email,
    "prefix": prefix,
    "phone": phone,
  };
}
