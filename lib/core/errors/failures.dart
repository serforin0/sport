sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de caché']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
