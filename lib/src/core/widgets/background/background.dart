import 'package:flutter/material.dart';

BoxDecoration globalDecoration() {
  return const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color.fromARGB(255, 8, 8, 8), Color.fromRGBO(144, 188, 88, 1)],
      stops: [0.0, 1.0],
      begin: FractionalOffset.topCenter,
      end: FractionalOffset.bottomCenter,
      tileMode: TileMode.repeated,
    ),
  );
}
