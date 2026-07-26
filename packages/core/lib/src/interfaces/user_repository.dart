import 'package:core/src/enums/user_role.dart';
import 'package:core/src/models/user_model.dart';

abstract class IUserRepository {
  Future<List<UserModel>> getUsers({UserRole? role});

  Future<UserModel?> getUser(String uid);

  Stream<List<UserModel>> watchUsers({UserRole? role});

  Future<int> getUsersCount();

  Future<int> getUsersCountByRole(UserRole role);
}
