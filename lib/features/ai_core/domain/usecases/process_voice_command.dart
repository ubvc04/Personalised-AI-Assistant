import '../entities/ai_entities.dart';
import '../repositories/ai_repository.dart';
import '../../../../core/utils/typedefs.dart';

class ProcessVoiceCommandUseCase extends UseCase<AIResponse, ProcessVoiceCommandParams> {
  final AIRepository repository;

  const ProcessVoiceCommandUseCase(this.repository);

  @override
  ResultFuture<AIResponse> call(ProcessVoiceCommandParams params) async {
    return repository.processVoiceCommand(
      command: params.command,
      context: params.context,
    );
  }
}

class ProcessVoiceCommandParams {
  final String command;
  final AIConversationContext context;

  const ProcessVoiceCommandParams({
    required this.command,
    required this.context,
  });
}