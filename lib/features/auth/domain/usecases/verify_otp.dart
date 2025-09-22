import '../repositories/auth_repository.dart';
import '../../../../core/utils/typedefs.dart';

class VerifyOTPUseCase extends UseCase<bool, VerifyOTPParams> {
  final AuthRepository repository;

  const VerifyOTPUseCase(this.repository);

  @override
  ResultFuture<bool> call(VerifyOTPParams params) async {
    return repository.verifyOTP(
      email: params.email,
      otp: params.otp,
      type: params.type,
    );
  }
}

class VerifyOTPParams {
  final String email;
  final String otp;
  final String type;

  const VerifyOTPParams({
    required this.email,
    required this.otp,
    required this.type,
  });
}