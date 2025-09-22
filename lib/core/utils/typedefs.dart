import '../errors/failures.dart';

typedef ResultFuture<T> = Future<Result<T>>;
typedef ResultVoid = Future<Result<void>>;
typedef DataMap = Map<String, dynamic>;

class Result<T> {
  final T? data;
  final Failure? failure;
  final bool isSuccess;

  const Result.success(this.data) : failure = null, isSuccess = true;
  const Result.failure(this.failure) : data = null, isSuccess = false;

  bool get isFailure => !isSuccess;

  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onFailure(failure!);
    }
  }
}

abstract class UseCase<Type, Params> {
  const UseCase();
  ResultFuture<Type> call(Params params);
}

abstract class UseCaseWithoutParams<Type> {
  const UseCaseWithoutParams();
  ResultFuture<Type> call();
}

class NoParams {
  const NoParams();
}