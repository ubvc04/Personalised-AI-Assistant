import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/utils/typedefs.dart';

class SignUpUseCase extends UseCase<User, SignUpParams> {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  @override
  ResultFuture<User> call(SignUpParams params) async {
    return repository.signUp(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  const SignUpParams({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });
}