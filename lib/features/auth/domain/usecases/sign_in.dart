import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/utils/typedefs.dart';

class SignInUseCase extends UseCase<User, SignInParams> {
  final AuthRepository repository;

  const SignInUseCase(this.repository);

  @override
  ResultFuture<User> call(SignInParams params) async {
    return repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });
}