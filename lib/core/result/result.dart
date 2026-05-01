import '../errors/failures.dart';

sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure f) onFailure, R Function(T data) onSuccess) {
    if (this is Ok<T>) {
      return onSuccess((this as Ok<T>).value);
    } else {
      return onFailure((this as Err<T>).failure);
    }
  }

  bool get isSuccess => this is Ok<T>;
  bool get isFailure => this is Err<T>;
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
