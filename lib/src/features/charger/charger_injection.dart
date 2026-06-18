import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/features/charger/data/datasources/charger_remote_data_source.dart';
import 'package:ecored_app/src/features/charger/domain/repositories/charger_repository_impl.dart';
import 'package:ecored_app/src/features/charger/domain/usecase/charger_services.dart';
import 'package:ecored_app/src/features/charger/presentation/provider/charger_provider.dart';
import 'package:provider/provider.dart';

String url = Environment.url;

final chargerProvider = [
  ChangeNotifierProvider(
    create: (_) {
      final dataSource = ChargerRemoteDataSourceImpl(url);
      final repository = ChargerRepositoryImpl(dataSource);
      final useCase = ChargerServices(repository);
      return ChargerProvider(useCase);
    },
  ),
];
