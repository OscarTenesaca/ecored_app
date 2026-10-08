import 'package:ecored_app/src/features/maps/data/model/model_charge_point.dart';
import 'package:ecored_app/src/features/maps/data/model/model_stations.dart';

/// Respuesta de `GET /station/preview/:id`: la estación junto con sus
/// puntos de carga físicos y los conectores de cada uno.
class ModelStationPreview {
  ModelStation station;
  List<ModelChargePoint> chargePoints;

  ModelStationPreview({required this.station, required this.chargePoints});

  factory ModelStationPreview.fromJson(Map<String, dynamic> json) =>
      ModelStationPreview(
        station: ModelStation.fromJson(json["station"]),
        chargePoints:
            (json["chargePoints"] as List? ?? [])
                .map((cp) => ModelChargePoint.fromJson(cp))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
    "station": station.toJson(),
    "chargePoints": chargePoints.map((cp) => cp.toJson()).toList(),
  };
}
