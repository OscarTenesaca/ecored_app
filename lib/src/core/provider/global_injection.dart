import 'package:ecored_app/src/core/provider/permissiongps_provider.dart';
import 'package:provider/provider.dart';

final globalProvider = [
  ChangeNotifierProvider(create: (_) => PermissionGpsProvider()),
];
