import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:flutter/foundation.dart';

class Environment {
  initialize() {
    if (kDebugMode) {
      Logger.logDev('Using Debug mode');
    } else if (kProfileMode) {
      Logger.logInfo('Using Profile mode');
    } else {
      Logger.logSuccess('Using Production mode');
    }
  }

  static String url =
      kDebugMode || kProfileMode
          ? 'http://192.168.18.37:3000'
          // ? 'http://localhost:3000'
          // ? 'http://10.0.2.2:3000'
          : 'https://bee.com.ec';
}
