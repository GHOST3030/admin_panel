import 'package:fpdart/fpdart.dart';
import '../errors/failure.dart';

abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

final class NoParams { const NoParams(); }
