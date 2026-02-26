import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:ecored_app/src/features/finance/domain/repositories/finance_repository_impl.dart';
import 'package:ecored_app/src/features/finance/domain/usecases/finance_services.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:ecored_app/src/features/maps/data/datasources/stations_remote_data_source.dart';
import 'package:ecored_app/src/features/maps/domain/repositories/station_repository_impl.dart';
import 'package:ecored_app/src/features/maps/domain/usecases/station_services.dart';
import 'package:provider/provider.dart';

String url = Environment.url;

final financeProviders = [
  ChangeNotifierProvider(
    create: (_) {
      final dataSource = FinanceRemoteDataSourceImpl(url);
      final repository = FinanceRepositoryImpl(dataSource);
      final useCase = FinanceServices(repository);

      // Inyectamos StationServices
      final dataSourceStation = StationsRemoteDataSourceImpl(url);
      final repositoryStation = StationRepositoryImpl(dataSourceStation);
      final useCaseStation = StationServices(repositoryStation);
      return FinanceProvider(
        services: useCase,
        stationServices: useCaseStation,
      );
    },
  ),
];
