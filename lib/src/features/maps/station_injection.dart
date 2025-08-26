import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/features/maps/data/datasources/stations_remote_data_source.dart';
import 'package:ecored_app/src/features/maps/domain/repositories/station_repository_impl.dart';
import 'package:ecored_app/src/features/maps/domain/usecases/station_services.dart';
import 'package:ecored_app/src/features/maps/presentation/provider/station_provider.dart';
import 'package:provider/provider.dart';

String url = Environment.url;

final stationProvider = [
  ChangeNotifierProvider(
    create: (_) {
      final dataSource = StationsRemoteDataSourceImpl(url);
      final repository = StationRepositoryImpl(dataSource);
      final useCase = StationServices(repository);
      return StationProvider(useCase);
    },
  ),
];
