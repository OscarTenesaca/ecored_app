// ?Stationn

enum ConnectionStatus { AVAILABLE, OCCUPIED, MAINTENANCE, OUT_OF_SERVICE }

const List<Map<String, String>> STATION_STATUS_LIST = [
  {'key': 'AVAILABLE', 'label': 'Disponible'},
  {'key': 'OCCUPIED', 'label': 'Ocupado'},
  {'key': 'MAINTENANCE', 'label': 'Mantenimiento'},
  {'key': 'OUT_OF_SERVICE', 'label': 'Fuera de Servicio'},
];

const List<Map<String, String>> STATION_TYPE_POINTS_LIST = [
  {'key': 'PUBLIC', 'label': '🌍 Público'},
  {'key': 'PARKING', 'label': '🅿️ Estacionamiento'},
  {'key': 'AIRPORT', 'label': '✈️ Aeropuerto'},
  {'key': 'CAMPING', 'label': '🏕️ Camping'},
  {'key': 'HOTEL', 'label': '🏨 Hotel'},
  {'key': 'PRIVATE', 'label': '🔒 Privado'},
  {'key': 'USER_PRIVATE', 'label': '🧑‍💻 Privado Usuario'},
  {'key': 'RESTAURANT', 'label': '🍽️ Restaurante'},
  {'key': 'SHOP', 'label': '🛍️ Tienda'},
  {'key': 'WORKPLACE', 'label': '🏢 Lugar de Trabajo'},
  {'key': 'STATION_SERVICE', 'label': '⛽ Servicio de Estación'},
  {'key': 'CONCESSIONAIRE', 'label': '🏪 Concesionario'},
  {'key': 'SHOPPING_CENTER', 'label': '🏬 Centro Comercial'},
  {'key': 'OTHER', 'label': '❓ Otro'},
];

// Charger types
const List<Map<String, String>> CONECTORS_TYPE_LIST = [
  {'key': 'CCS2', 'label': 'CCS2'},
  {'key': 'CCS1', 'label': 'CCS1'},
  {'key': 'TYPE_2', 'label': 'Type 2'},
  {'key': 'SCHUKO', 'label': 'Schuko'},
  {'key': 'CHADEMO', 'label': 'CHAdeMO'},
  {'key': 'TYPE_E', 'label': 'Type E'},
  {'key': 'TYPE_G', 'label': 'Type G'},
  {'key': 'TYPE_H', 'label': 'Type H'},
  {'key': 'TYPE3C', 'label': 'Type 3C'},
  {'key': 'UNKNOWN', 'label': 'Unknown'},
];

const List<Map<String, String>> CHARGER_TYPE_LIST = [
  {'key': 'AC1', 'label': 'Monofásico (AC)'},
  {'key': 'AC3', 'label': 'Trifásico (AC)'},
  {'key': 'CC', 'label': 'Corriente Continua (CC)'},
];
