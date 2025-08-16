import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/features/login/data/datasources/login_remote_data_source.dart';
import 'package:ecored_app/src/features/login/domain/repositories/login_repository_impl.dart';
import 'package:ecored_app/src/features/login/domain/usecases/login_services.dart';
import 'package:ecored_app/src/features/login/presentation/provider/login_provider.dart';
import 'package:provider/provider.dart';

String url = Environment.url;

final loginProviders = [
  ChangeNotifierProvider(
    create: (_) {
      final dataSource = LoginRemoteDataSourceImpl(url);
      final repository = LoginRepositoryImpl(dataSource);
      final useCase = LoginServices(repository);
      return LoginProvider(useCase);
    },
  ),
];
