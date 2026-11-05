import '../constants/app_constants.dart';

/// 后端统一响应信封：
///
/// ```json
/// { "code": 0, "message": "ok", "data": <T> }
/// ```
///
/// 字段命名与成功码语义 TODO(backend): 待后端确认。
class ApiResponse<T> {
  const ApiResponse({required this.code, required this.message, this.data});

  final int code;
  final String message;
  final T? data;

  bool get isSuccess => code == AppConstants.successCode;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? raw)? parseData,
  ) {
    return ApiResponse<T>(
      code: (json['code'] as num?)?.toInt() ?? -1,
      message: json['message'] as String? ?? '',
      data: parseData?.call(json['data']),
    );
  }
}
