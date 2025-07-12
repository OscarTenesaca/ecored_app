import 'package:flutter/material.dart';

// Definición de colores constantes
const Color kPrimaryColor = Color.fromRGBO(26, 26, 26, 1); // Negro
// const Color kAccentColor = Color.fromRGBO(225, 215, 63, 1); // Amarillo
const Color kAccentColor = Color.fromRGBO(144, 188, 88, 1); // Amarillo

const Color kGreyColorTransparency = Color.fromRGBO(97, 97, 97, 0.5);
const Color kWhiteColor = Color.fromRGBO(255, 255, 255, 1); // Blanco
const Color kGrayInputColor = Color.fromRGBO(147, 147, 147, 1); // Gris sólido

// Uso de las constantes de color en funciones si es necesario
Color primaryColor() => kPrimaryColor;
Color accentColor() => kAccentColor;
Color whiteColor() => kWhiteColor;
Color greyColorWithTransparency() => kGreyColorTransparency;
Color grayInputColor() => kGrayInputColor;
