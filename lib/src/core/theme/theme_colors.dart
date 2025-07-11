import 'package:flutter/material.dart';

// Definición de colores constantes
const Color kPrimaryColor = Color.fromRGBO(0, 0, 0, 1); // Negro
const Color kAccentColor = Color.fromARGB(255, 234, 63, 63); // Amarillo

const Color kGreyColorTransparency = Color.fromRGBO(97, 97, 97, 0.5);
const Color kWhiteColor = Color.fromRGBO(255, 255, 255, 1); // Blanco
const Color kGrayInputColor = Color.fromRGBO(147, 147, 147, 1); // Gris sólido

// Uso de las constantes de color en funciones si es necesario
Color primaryColor() => kPrimaryColor;
Color accentColor() => kAccentColor;
Color greyColorWithTransparency() => kGreyColorTransparency;
Color whiteColor() => kWhiteColor;
Color grayInputColor() => kGrayInputColor;
