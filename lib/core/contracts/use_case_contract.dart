typedef AsyncResult<T> = Future<T>;
typedef Result<T> = T;

abstract class UseCaseParams {
  const UseCaseParams();
}

final class NoParams extends UseCaseParams {
  const NoParams();
}

abstract class UseCase<TOutput, TParams extends UseCaseParams> {
  AsyncResult<TOutput> call(TParams params);
}
