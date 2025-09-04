import '../error/failures.dart';

/// 结果类型，封装成功和失败状态
sealed class Result<T> {
  const Result();

  /// 成功结果
  const factory Result.success(T data) = Success<T>;

  /// 失败结果
  const factory Result.failure(Failure failure) = Failed<T>;

  /// 是否成功
  bool get isSuccess => this is Success<T>;

  /// 是否失败
  bool get isFailure => this is Failed<T>;

  /// 获取数据（仅在成功时）
  T? get data => isSuccess ? (this as Success<T>).data : null;

  /// 获取失败信息（仅在失败时）
  Failure? get failure => isFailure ? (this as Failed<T>).failure : null;

  /// 当成功时执行回调
  Result<T> onSuccess(void Function(T data) callback) {
    if (isSuccess) {
      callback((this as Success<T>).data);
    }
    return this;
  }

  /// 当失败时执行回调
  Result<T> onFailure(void Function(Failure failure) callback) {
    if (isFailure) {
      callback((this as Failed<T>).failure);
    }
    return this;
  }

  /// 映射数据
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess) {
      try {
        return Result.success(mapper((this as Success<T>).data));
      } catch (e) {
        return Result.failure(UnknownFailure(e.toString()));
      }
    }
    return Result.failure((this as Failed<T>).failure);
  }

  /// 异步映射数据
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) mapper) async {
    if (isSuccess) {
      try {
        final result = await mapper((this as Success<T>).data);
        return Result.success(result);
      } catch (e) {
        return Result.failure(UnknownFailure(e.toString()));
      }
    }
    return Result.failure((this as Failed<T>).failure);
  }

  /// 平铺映射
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    if (isSuccess) {
      return mapper((this as Success<T>).data);
    }
    return Result.failure((this as Failed<T>).failure);
  }

  /// 获取数据或默认值
  T getOrElse(T defaultValue) {
    return isSuccess ? (this as Success<T>).data : defaultValue;
  }

  /// 获取数据或通过回调生成默认值
  T getOrElseWith(T Function(Failure failure) defaultValue) {
    return isSuccess
        ? (this as Success<T>).data
        : defaultValue((this as Failed<T>).failure);
  }
}

/// 成功结果
final class Success<T> extends Result<T> {
  const Success(this.data);

  @override
  final T data;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// 失败结果
final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  @override
  final Failure failure;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failed<T> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Failed($failure)';
}
