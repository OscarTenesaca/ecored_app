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
  double value;
  String devReference;
  String authorizationCode;
  String transactionId;
  String user;
  Payments payment;
  String createdAt;
  String? reason;
  String? updatedAt;
  // Snapshot de país/provincia del usuario al crear la recarga (ObjectId; el
  // backend no los puebla en GET /recharges/:id).
  String? country;
  String? province;
  // IVA incluido en `value` (porcentaje entero, ej. 15) y su desglose.
  double? taxPercentage;
  double? tax;
  double? subtotal;
  // Comisión de la pasarela de pago (porcentaje entero, ej. 8) en dinero.
  double? paymentPercentage;
  double? paymentValue;

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
    this.reason,
    this.updatedAt,
    this.country,
    this.province,
    this.taxPercentage,
    this.tax,
    this.subtotal,
    this.paymentPercentage,
    this.paymentValue,
  });

  factory ModelRecharge.fromJson(Map<String, dynamic> json) => ModelRecharge(
    id: json["_id"],
    statusCreated: json["statusCreated"],
    status: json["status"],
    value: json["value"].toDouble(),
    devReference: json["devReference"],
    authorizationCode: json["authorizationCode"],
    transactionId: json["transactionId"],
    user: json["user"],
    payment: Payments.fromJson(json["payment"]),
    createdAt: json["createdAt"],
    reason: json["reason"],
    updatedAt: json["updatedAt"],
    country: _refId(json["country"]),
    province: _refId(json["province"]),
    taxPercentage: (json["taxPercentage"] as num?)?.toDouble(),
    tax: (json["tax"] as num?)?.toDouble(),
    subtotal: (json["subtotal"] as num?)?.toDouble(),
    paymentPercentage: (json["paymentPercentage"] as num?)?.toDouble(),
    paymentValue: (json["paymentValue"] as num?)?.toDouble(),
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
    "reason": reason,
    "updatedAt": updatedAt,
    "country": country,
    "province": province,
    "taxPercentage": taxPercentage,
    "tax": tax,
    "subtotal": subtotal,
    "paymentPercentage": paymentPercentage,
    "paymentValue": paymentValue,
  };
}

// Acepta tanto el ObjectId plano como un documento poblado ({_id, name}).
String? _refId(dynamic value) {
  if (value == null) return null;
  if (value is Map) return value["_id"]?.toString();
  return value.toString();
}

class Payments {
  String id;
  String name;

  Payments({required this.id, required this.name});

  factory Payments.fromJson(Map<String, dynamic> json) =>
      Payments(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}
