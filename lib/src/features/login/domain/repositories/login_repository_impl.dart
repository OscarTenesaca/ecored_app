import 'package:ecored_app/src/features/login/data/datasources/login_remote_data_source.dart';
import 'package:ecored_app/src/features/login/data/models/model_user.dart';
import 'package:ecored_app/src/features/login/domain/repositories/login_repository.dart';

// CLASS FIVE

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl(this.remoteDataSource);

  @override
  Future<ModelUser> registerUser(Map<String, dynamic> userData) {
    return remoteDataSource.registerUser(userData);
  }

  @override
  Future<ModelUser> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<int> logout() {
    return remoteDataSource.logout();
  }

  @override
  Future<int> saveFCM(Map<String, dynamic> body) {
    // TODO: implement saveFCM
    throw UnimplementedError();
  }
}
