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
  String operationStatus;
  double pricePerKwh;
  double tax;
  double subtotal;
  double total;
  int discount;
  int discountTotal;
  User user;
  Stations stations;
  Charger charger;
  int connectorId;
  Country country;
  String administrator;
  int meterStart;
  int meterStop;
  double kWhDelivered;
  int socStart;
  double soc;
  int batteryCapacityKwh;
  String stopReason;
  String idTag;
  String createdAt;
  int ocppTransactionId;
  double currentPowerKw;

  ModelOrder({
    required this.id,
    required this.platformBuy,
    required this.status,
    required this.operationStatus,
    required this.pricePerKwh,
    required this.tax,
    required this.subtotal,
    required this.total,
    required this.discount,
    required this.discountTotal,
    required this.user,
    required this.stations,
    required this.charger,
    required this.connectorId,
    required this.country,
    required this.administrator,
    required this.meterStart,
    required this.meterStop,
    required this.kWhDelivered,
    required this.socStart,
    required this.soc,
    required this.batteryCapacityKwh,
    required this.stopReason,
    required this.idTag,
    required this.createdAt,
    required this.ocppTransactionId,
    this.currentPowerKw = 0,
  });

  factory ModelOrder.fromJson(Map<String, dynamic> json) => ModelOrder(
    id: json["_id"],
    platformBuy: json["platformBuy"],
    status: json["status"],
    operationStatus: json["operationStatus"],
    pricePerKwh: json["pricePerKwh"]?.toDouble(),
    tax: json["tax"]?.toDouble(),
    subtotal: json["subtotal"]?.toDouble(),
    total: json["total"]?.toDouble(),
    discount: json["discount"],
    discountTotal: json["discountTotal"],
    user:
        json["user"] is String
            ? User(
              id: json["user"],
              ci: '',
              name: '',
              email: '',
              prefix: '',
              phone: '',
            )
            : User.fromJson(json["user"]),
    stations: Stations.fromJson(json["stations"]),
    charger: Charger.fromJson(json["charger"]),
    connectorId: json["connectorId"],
    country: Country.fromJson(json["country"]),
    administrator: json["administrator"],
    meterStart: json["meterStart"],
    meterStop: json["meterStop"],
    kWhDelivered: json["kWhDelivered"]?.toDouble(),
    socStart: json["socStart"],
    soc: json["soc"]?.toDouble(),
    batteryCapacityKwh: json["batteryCapacityKwh"],
    stopReason: json["stopReason"],
    idTag: json["idTag"],
    createdAt: json["createdAt"],
    ocppTransactionId: json["ocppTransactionId"],
    currentPowerKw: (json["currentPowerKw"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "platformBuy": platformBuy,
    "status": status,
    "operationStatus": operationStatus,
    "pricePerKwh": pricePerKwh,
    "tax": tax,
    "subtotal": subtotal,
    "total": total,
    "discount": discount,
    "discountTotal": discountTotal,
    "user": user.toJson(),
    "stations": stations.toJson(),
    "charger": charger.toJson(),
    "connectorId": connectorId,
    "country": country.toJson(),
    "administrator": administrator,
    "meterStart": meterStart,
    "meterStop": meterStop,
    "kWhDelivered": kWhDelivered,
    "socStart": socStart,
    "soc": soc,
    "batteryCapacityKwh": batteryCapacityKwh,
    "stopReason": stopReason,
    "idTag": idTag,
    "createdAt": createdAt,
    "ocppTransactionId": ocppTransactionId,
    "currentPowerKw": currentPowerKw,
  };

  /// Aplica una actualización parcial (p. ej. proveniente del evento de
  /// socket `orderUpdate`) sobre este pedido, devolviendo una copia.
  ///
  /// El backend emite ese evento con `Order.findByIdAndUpdate(...)` SIN
  /// `.populate()`, así que `user`/`stations`/`charger`/`country` llegan
  /// como IDs planos, no como los objetos completos que sí devuelve el
  /// endpoint REST normal. Por eso aquí solo se toman del payload los
  /// campos que realmente cambian mientras se carga (energía, potencia,
  /// costos, estado); todo lo demás se conserva del pedido ya cargado.
  ModelOrder applyProgress(Map<String, dynamic> json) {
    return ModelOrder(
      id: id,
      platformBuy: platformBuy,
      status: json["status"] ?? status,
      operationStatus: json["operationStatus"] ?? operationStatus,
      pricePerKwh: json["pricePerKwh"]?.toDouble() ?? pricePerKwh,
      tax: json["tax"]?.toDouble() ?? tax,
      subtotal: json["subtotal"]?.toDouble() ?? subtotal,
      total: json["total"]?.toDouble() ?? total,
      discount: discount,
      discountTotal: discountTotal,
      user: user,
      stations: stations,
      charger: charger,
      connectorId: connectorId,
      country: country,
      administrator: administrator,
      meterStart: json["meterStart"] ?? meterStart,
      meterStop: json["meterStop"] ?? meterStop,
      kWhDelivered: json["kWhDelivered"]?.toDouble() ?? kWhDelivered,
      socStart: socStart,
      soc: json["soc"]?.toDouble() ?? soc,
      batteryCapacityKwh: batteryCapacityKwh,
      stopReason: json["stopReason"] ?? stopReason,
      idTag: idTag,
      createdAt: createdAt,
      ocppTransactionId: ocppTransactionId,
      currentPowerKw: json["currentPowerKw"]?.toDouble() ?? currentPowerKw,
    );
  }
}

class Charger {
  String id;
  String typeConnection;
  String code;

  Charger({required this.id, required this.typeConnection, required this.code});

  factory Charger.fromJson(Map<String, dynamic> json) => Charger(
    id: json["_id"],
    typeConnection: json["typeConnection"],
    code: json["code"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "typeConnection": typeConnection,
    "code": code,
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

// // To parse this JSON data, do
// //
// //     final modelOrder = modelOrderFromJson(jsonString);

// import 'dart:convert';

// ModelOrder modelOrderFromJson(String str) =>
//     ModelOrder.fromJson(json.decode(str));

// String modelOrderToJson(ModelOrder data) => json.encode(data.toJson());

// class ModelOrder {
//   String id;
//   String platformBuy;
//   String status;
//   double tax;
//   double subtotal;
//   double total;
//   double discount;
//   double discountTotal;
//   User user;
//   Stations stations;
//   Charger charger;
//   // String recharge;
//   Country country;
//   String createdAt;

//   ModelOrder({
//     required this.id,
//     required this.platformBuy,
//     required this.status,
//     required this.tax,
//     required this.subtotal,
//     required this.total,
//     required this.discount,
//     required this.discountTotal,
//     required this.user,
//     required this.stations,
//     required this.charger,
//     // required this.recharge,
//     required this.country,
//     required this.createdAt,
//   });

//   factory ModelOrder.fromJson(Map<String, dynamic> json) => ModelOrder(
//     id: json["_id"],
//     platformBuy: json["platformBuy"],
//     status: json["status"],
//     tax: json["tax"]?.toDouble(),
//     subtotal: json["subtotal"]?.toDouble(),
//     total: json["total"]?.toDouble(),
//     discount: json["discount"]?.toDouble(),
//     discountTotal: json["discountTotal"]?.toDouble(),
//     user: User.fromJson(json["user"]),
//     stations: Stations.fromJson(json["stations"]),
//     charger: Charger.fromJson(json["charger"]),
//     // recharge: json["recharge"],
//     country: Country.fromJson(json["country"]),
//     createdAt: json["createdAt"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "platformBuy": platformBuy,
//     "status": status,
//     "tax": tax,
//     "subtotal": subtotal,
//     "total": total,
//     "discount": discount,
//     "discountTotal": discountTotal,
//     "user": user.toJson(),
//     "stations": stations.toJson(),
//     "charger": charger.toJson(),
//     // "recharge": recharge,
//     "payment": payment.toJson(),
//     "country": country.toJson(),
//     "createdAt": createdAt,
//   };
// }

// class Charger {
//   String id;
//   String typeConnection;

//   Charger({required this.id, required this.typeConnection});

//   factory Charger.fromJson(Map<String, dynamic> json) =>
//       Charger(id: json["_id"], typeConnection: json["typeConnection"]);

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "typeConnection": typeConnection,
//   };
// }

// class Country {
//   String id;
//   String name;
//   String code;

//   Country({required this.id, required this.name, required this.code});

//   factory Country.fromJson(Map<String, dynamic> json) =>
//       Country(id: json["_id"], name: json["name"], code: json["code"]);

//   Map<String, dynamic> toJson() => {"_id": id, "name": name, "code": code};
// }

// class Payment {
//   String id;
//   String name;

//   Payment({required this.id, required this.name});

//   factory Payment.fromJson(Map<String, dynamic> json) =>
//       Payment(id: json["_id"], name: json["name"]);

//   Map<String, dynamic> toJson() => {"_id": id, "name": name};
// }

// class Stations {
//   String id;
//   String name;
//   String address;
//   String prefixCode;
//   String phone;

//   Stations({
//     required this.id,
//     required this.name,
//     required this.address,
//     required this.prefixCode,
//     required this.phone,
//   });

//   factory Stations.fromJson(Map<String, dynamic> json) => Stations(
//     id: json["_id"],
//     name: json["name"],
//     address: json["address"],
//     prefixCode: json["prefixCode"],
//     phone: json["phone"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "name": name,
//     "address": address,
//     "prefixCode": prefixCode,
//     "phone": phone,
//   };
// }

// class User {
//   String id;
//   String ci;
//   String name;
//   String email;
//   String prefix;
//   String phone;

//   User({
//     required this.id,
//     required this.ci,
//     required this.name,
//     required this.email,
//     required this.prefix,
//     required this.phone,
//   });

//   factory User.fromJson(Map<String, dynamic> json) => User(
//     id: json["_id"],
//     ci: json["ci"],
//     name: json["name"],
//     email: json["email"],
//     prefix: json["prefix"],
//     phone: json["phone"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "ci": ci,
//     "name": name,
//     "email": email,
//     "prefix": prefix,
//     "phone": phone,
//   };
// }
