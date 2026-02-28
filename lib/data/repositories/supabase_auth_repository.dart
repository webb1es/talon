import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final sb.SupabaseClient _client;
  UserRole _activeRole = UserRole.cashier;

  SupabaseAuthRepository(this._client);

  @override
  User? get currentUser {
    final session = _client.auth.currentUser;
    if (session == null) return null;
    return User(
      id: session.id,
      email: session.email ?? '',
      name: session.userMetadata?['name'] as String? ??
          session.email?.split('@').first ??
          '',
      role: _activeRole,
    );
  }

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return const Fail(ServerFailure('Login failed'));
      }
      _activeRole = role;
      return Success(currentUser!);
    } on sb.AuthException catch (e) {
      return Fail(ServerFailure(e.message));
    } catch (e) {
      return Fail(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _client.auth.signOut();
      return const Success(null);
    } on sb.AuthException catch (e) {
      return Fail(ServerFailure(e.message));
    }
  }
}
