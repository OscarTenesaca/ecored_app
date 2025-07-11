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
          ? 'https://getbeeapp.com'
          : 'https://bee.com.ec';
}
