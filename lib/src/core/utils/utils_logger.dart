// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

enum LogType { info, warning, error, success, dev }

class Logger {
  static void log(
    String message, {
    Color? messageColor,
    LogType type = LogType.info,
    required String tag,
    bool showStackTrace =
        false, // Parámetro para mostrar u ocultar el stack trace
    int stackTraceLinesToShow = 3, // Número de líneas del stack trace a mostrar
  }) {
    List<String> stackTraceLines = StackTrace.current.toString().split('\n');

    // Tomar solo las primeras `stackTraceLinesToShow` líneas si es necesario
    if (showStackTrace &&
        stackTraceLinesToShow > 0 &&
        stackTraceLines.length > stackTraceLinesToShow) {
      stackTraceLines = stackTraceLines.sublist(0, stackTraceLinesToShow);
    }

    messageColor ??= _getColorForLogType(type);

    int ansiColorCode = _getAnsiColorCode(messageColor);

    // Imprimir el mensaje principal con el mismo color que el tag
    print('\x1B[${ansiColorCode}m$tag $message\x1B[0m');

    // Imprimir cada línea del stack trace con un formato especial si showStackTrace es verdadero
    if (showStackTrace) {
      for (int i = 0; i < stackTraceLines.length; i++) {
        String line = stackTraceLines[i];
        // Formatear las líneas del stack trace para que estén indentadas jerárquicamente
        final match = RegExp(
          r'^(#\d+\s+)?(.+?\.dart):(\d+):(\d+)',
        ).firstMatch(line);
        if (match != null) {
          final filePath = match.group(2);
          final lineNumber = match.group(3);
          final columnNumber = match.group(4);
          // Construir la indentación jerárquica con guiones
          final indentation =
              '\x1B[${ansiColorCode}m│\x1B[0m ' * i +
              '\x1B[${ansiColorCode}m├─\x1B[0m';
          // Imprimir la línea del stack trace con la indentación
          print('$indentation $filePath:$lineNumber:$columnNumber');
        } else {
          // Agregar guiones de indentación antes de las líneas que no contienen información del archivo
          final indentation =
              '\x1B[${ansiColorCode}m│\x1B[0m ' * i +
              '\x1B[${ansiColorCode}m├─\x1B[0m';
          print('$indentation $line');
        }
      }
    }
  }

  static void logInfo(String message, {bool showStackTrace = false}) {
    log(
      message,
      type: LogType.info,
      tag: 'ℹ️ - Info -',
      showStackTrace: showStackTrace,
    );
  }

  static void logWarning(String message, {bool showStackTrace = false}) {
    log(
      message,
      type: LogType.warning,
      tag: '⚠️ - Warning -',
      showStackTrace: showStackTrace,
    );
  }

  static void logError(String message, {bool showStackTrace = false}) {
    log(
      message,
      type: LogType.error,
      tag: '❌ - Error -',
      showStackTrace: showStackTrace,
    );
  }

  static void logSuccess(String message, {bool showStackTrace = false}) {
    log(
      message,
      type: LogType.success,
      tag: '✅ - Success -',
      showStackTrace: showStackTrace,
    );
  }

  static void logDev(String message, {bool showStackTrace = false}) {
    log(
      message,
      type: LogType.dev,
      tag: '🔧 - Dev -',
      showStackTrace: showStackTrace,
    );
  }

  static Color _getColorForLogType(LogType type) {
    switch (type) {
      case LogType.info:
        return Colors.blue;
      case LogType.warning:
        return Colors.orange;
      case LogType.error:
        return Colors.red;
      case LogType.success:
        return Colors.green;
      case LogType.dev:
        return Colors.purple;
    }
  }

  static int _getAnsiColorCode(Color color) {
    if (color == Colors.red) {
      return 31;
    } else if (color == Colors.green) {
      return 32;
    } else if (color == Colors.yellow || color == Colors.orange) {
      return 33;
    } else if (color == Colors.blue) {
      return 34;
    } else if (color == Colors.purple) {
      return 35;
    } else {
      return 0; // Default color (black)
    }
  }
}
