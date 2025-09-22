import '../entities/ai_entities.dart';
import '../repositories/ai_repository.dart';
import '../../../../core/utils/typedefs.dart';

class SendMessageUseCase extends UseCase<AIResponse, SendMessageParams> {
  final AIRepository repository;

  const SendMessageUseCase(this.repository);

  @override
  ResultFuture<AIResponse> call(SendMessageParams params) async {
    return repository.sendMessage(
      message: params.message,
      context: params.context,
    );
  }
}

class SendMessageParams {
  final String message;
  final AIConversationContext context;

  const SendMessageParams({
    required this.message,
    required this.context,
  });
}