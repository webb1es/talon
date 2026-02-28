import 'package:uuid/uuid.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty || password.isEmpty) {
      return const Fail(ValidationFailure('Email and password are required'));
    }

    _currentUser = User(
      id: const Uuid().v4(),
      email: email,
      name: email.split('@').first,
      role: role,
    );
    return Success(_currentUser!);
  }

  @override
  Future<Result<void>> logout() async {
    _currentUser = null;
    return const Success(null);
  }
}
