import 'package:ecored_app/src/core/widgets/maps/map.dart';
import 'package:flutter/material.dart';

class PageHome extends StatelessWidget {
  const PageHome({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map> latLngMarkers = [
      {'_id': 'aoeurcgc', 'lat': -2.888100139166612, 'lng': -78.98455544907367},
      {'_id': 'aoeurcgc', 'lat': -2.9014499915134335, 'lng': -78.9937269702811},
      {'_id': 'aoeurcgc', 'lat': -2.89698963821467, 'lng': -79.00210722955012},
      {'_id': 'aoeurcgc', 'lat': -2.903732995835395, 'lng': -79.0187781133494},
    ];

    return Scaffold(body: CustomMap(latLngMarkers: latLngMarkers));
  }
}
