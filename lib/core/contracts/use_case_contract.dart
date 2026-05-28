import 'package:result_dart/result_dart.dart';

abstract class UseCaseParams {
  const UseCaseParams();
}

final class NoParams extends UseCaseParams {
  const NoParams();
}

final class UseCaseOutput extends Object {}

abstract class UseCase<T extends Object, Input> {
  AsyncResult<T> call(Input input);
}
