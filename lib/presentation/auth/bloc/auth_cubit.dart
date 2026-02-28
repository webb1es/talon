import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_role.dart';
import '../../../domain/repositories/auth_repository.dart';

// -- State --

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final Failure failure;
  const AuthError(this.failure);
}

// -- Cubit --

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const Unauthenticated());

  bool get isAuthenticated => state is Authenticated;

  Future<void> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    emit(const AuthLoading());
    final result = await _authRepository.login(
      email: email,
      password: password,
      role: role,
    );
    switch (result) {
      case Success(:final data):
        emit(Authenticated(data));
      case Fail(:final failure):
        emit(AuthError(failure));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const Unauthenticated());
  }
}
