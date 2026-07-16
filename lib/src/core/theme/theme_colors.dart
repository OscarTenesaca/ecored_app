import 'package:flutter/material.dart';

// Definición de colores constantes
// const Color kPrimaryColor = Color.fromRGBO(0, 0, 7, 1); // Negro
const Color kPrimaryColor = Color(0xFF0E1411);
const Color kGrayInputColor = Color.fromRGBO(170, 179, 187, 1); // Gris sólido
const Color kWhiteColor = Color.fromRGBO(255, 255, 255, 1); // Blanco
// const Color kAccentColor = Color.fromRGBO(178, 235, 0, 1); // Green
const Color kAccentColor = Color(0xFFA6FF00); // Green
const Color kflatGreen = Color.fromRGBO(106, 146, 58, 1.0); // Green
const Color krefreshingMint = Color.fromRGBO(131, 189, 69, 1.0); // Green

const Color kGreyColorTransparency = Color.fromRGBO(97, 97, 97, 0.5);
const Color kDeepForestGreen = Color(0xFF161C18);

// alert colors success, error, warning, info
const Color kSuccessColor = Color.fromRGBO(76, 175, 80, 1); // Verde
const Color kErrorColor = Color.fromRGBO(244, 67, 54, 1); // Rojo
const Color kWarningColor = Color.fromRGBO(255, 152, 0, 1); // Naranja
const Color kInfoColor = Color.fromRGBO(33, 150, 243, 1); // Azul

// Uso de las constantes de color en funciones si es necesario
Color primaryColor() => kPrimaryColor;
Color grayInputColor() => kGrayInputColor;
Color whiteColor() => kWhiteColor;
Color accentColor() => kAccentColor;
Color flatGreen() => kflatGreen;
Color refreshingMint() => krefreshingMint;
Color deepForestGreen() => kDeepForestGreen;

Color greyColorWithTransparency() => kGreyColorTransparency;
Color successColor() => kSuccessColor;
Color errorColor() => kErrorColor;
Color warningColor() => kWarningColor;
Color infoColor() => kInfoColor;
