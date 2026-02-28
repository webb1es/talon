import '../entities/user.dart';
import '../entities/user_role.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Result<User>> login({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<Result<void>> logout();

  User? get currentUser;
}
