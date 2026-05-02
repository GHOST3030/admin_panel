import 'package:fpdart/fpdart.dart';
import '../errors/failure.dart';

abstract interface class UseCase<Typee, Params> {
  Future<Either<Failure, Typee>> call(Params params);
}

final class NoParams { const NoParams(); }
