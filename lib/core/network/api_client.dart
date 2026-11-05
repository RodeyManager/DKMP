import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'api_exception.dart';
import 'api_response.dart';

/// 基于 Dio 的统一 HTTP 客户端。
///
/// TODO: 登录体系落地后补充统一的鉴权 / 刷新 token 拦截器。
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout:
            const Duration(seconds: AppConstants.connectTimeoutSeconds),
        receiveTimeout:
            const Duration(seconds: AppConstants.receiveTimeoutSeconds),
        responseType: ResponseType.json,
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(requestBody: true));
    }
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Object? raw)? parse,
  }) {
    return _send(
      () => _dio.get<dynamic>(path, queryParameters: queryParameters),
      parse,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    T Function(Object? raw)? parse,
  }) {
    return _send(() => _dio.post<dynamic>(path, data: data), parse);
  }

  Future<ApiResponse<T>> _send<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Object? raw)? parse,
  ) async {
    Response<dynamic> response;
    try {
      response = await request();
    } on DioException catch (e) {
      throw ApiException.network(e);
    } catch (_) {
      // 非 Dio 异常（如反序列化失败），统一按格式异常处理。
      throw ApiException('服务端返回格式异常，请稍后重试');
    }

    final Object? body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ApiException('服务端返回格式异常，请稍后重试');
    }

    final ApiResponse<T> apiResponse = ApiResponse<T>.fromJson(body, parse);
    if (!apiResponse.isSuccess) {
      throw ApiException(
        apiResponse.message.isEmpty ? '请求失败，请稍后重试' : apiResponse.message,
        code: apiResponse.code,
      );
    }
    return apiResponse;
  }
}
