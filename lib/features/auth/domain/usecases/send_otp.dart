import '../repositories/auth_repository.dart';
import '../../../../core/utils/typedefs.dart';

class SendOTPUseCase extends UseCase<void, SendOTPParams> {
  final AuthRepository repository;

  const SendOTPUseCase(this.repository);

  @override
  ResultFuture<void> call(SendOTPParams params) async {
    return repository.sendOTP(
      email: params.email,
      type: params.type,
    );
  }
}

class SendOTPParams {
  final String email;
  final String type;

  const SendOTPParams({
    required this.email,
    required this.type,
  });
}