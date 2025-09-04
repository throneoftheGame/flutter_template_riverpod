import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// API 响应基础模型
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  const ApiResponse({required this.code, required this.message, this.data});

  /// 响应码
  final int code;

  /// 响应消息
  final String message;

  /// 响应数据
  final T? data;

  /// 是否成功
  bool get isSuccess => code == 200 || code == 0;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  @override
  String toString() =>
      'ApiResponse(code: $code, message: $message, data: $data)';
}

/// 分页响应模型
@JsonSerializable(genericArgumentFactories: true)
class PageResponse<T> {
  const PageResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  /// 数据列表
  final List<T> list;

  /// 总数量
  final int total;

  /// 当前页码
  final int page;

  /// 每页大小
  final int pageSize;

  /// 是否有更多数据
  bool get hasMore => list.length >= pageSize;

  /// 总页数
  int get totalPages => (total / pageSize).ceil();

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PageResponseToJson(this, toJsonT);

  @override
  String toString() =>
      'PageResponse(list: ${list.length} items, total: $total, page: $page, pageSize: $pageSize)';
}
