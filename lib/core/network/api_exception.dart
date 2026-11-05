import 'package:dio/dio.dart';

/// 统一业务异常：携带用户可直接展示的 message 与后端业务码。
class ApiException implements Exception {
  ApiException(this.message, {this.code});

  /// 用户可直接展示的错误描述。
  final String message;

  /// 后端业务错误码；网络类异常为 null。
  final int? code;

  /// 将底层异常包装为用户可读的业务异常。
  factory ApiException.network(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException('网络请求超时，请稍后重试');
        case DioExceptionType.connectionError:
          return ApiException('网络连接失败，请检查网络后重试');
        case DioExceptionType.badResponse:
          return ApiException('服务异常（${error.response?.statusCode ?? '未知状态'}），请稍后重试');
        case DioExceptionType.cancel:
          return ApiException('请求已取消');
        default:
          return ApiException('网络异常，请稍后重试');
      }
    }
    return ApiException('网络异常，请稍后重试');
  }

  @override
  String toString() => 'ApiException($code): $message';
}
