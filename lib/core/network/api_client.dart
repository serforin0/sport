import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/core/config/api_config.dart';

// moved to core/providers/shared_preferences_provider.dart

final apiClientProvider = Provider<ApiClient>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ApiClient(baseUrl: kApiBaseUrl, sharedPreferences: prefs);
});

class ApiClient {
  final String baseUrl;
  final Dio dio;
  late final Dio _fallbackDio;
  final SharedPreferences sharedPreferences;

  ApiClient({required this.baseUrl, required this.sharedPreferences})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          followRedirects: true,
          maxRedirects: 5,
          headers: {'Accept': 'application/json'},
        ),
      ) {
    _fallbackDio = Dio(
      BaseOptions(
        baseUrl: kApiFallbackBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        followRedirects: true,
        maxRedirects: 5,
        headers: {'Accept': 'application/json'},
      ),
    );
    _addAuthInterceptor(dio);
    _addAuthInterceptor(_fallbackDio);
  }

  void _addAuthInterceptor(Dio client) {
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = sharedPreferences.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (_shouldRetrySecurely(e)) {
        return _fallbackDio.get(
          path,
          queryParameters: queryParameters,
          options: options,
        );
      }
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (_shouldRetrySecurely(e)) {
        return _fallbackDio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      }
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (_shouldRetrySecurely(e)) {
        return _fallbackDio.patch(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      }
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (_shouldRetrySecurely(e)) {
        return _fallbackDio.put(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      }
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (_shouldRetrySecurely(e)) {
        return _fallbackDio.delete(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      }
      throw _handleError(e);
    }
  }

  bool _shouldRetrySecurely(DioException e) {
    final message = [
      e.message,
      e.error?.toString(),
    ].whereType<String>().join(' ').toLowerCase();

    final primaryUri = Uri.tryParse(baseUrl);
    final fallbackUri = Uri.tryParse(kApiFallbackBaseUrl);
    final hasSafeFallback =
        primaryUri?.scheme == 'https' &&
        fallbackUri?.scheme == 'https' &&
        primaryUri?.host == fallbackUri?.host &&
        baseUrl != kApiFallbackBaseUrl;

    return hasSafeFallback &&
        (message.contains('handshake') ||
            message.contains('certificate') ||
            message.contains('tls') ||
            message.contains('ssl'));
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception(
        'API Error (${e.response?.statusCode}): ${e.response?.data}',
      );
    }
    final details = [
      e.type.name,
      if (e.message != null && e.message!.trim().isNotEmpty) e.message,
      if (e.error != null) e.error.toString(),
    ].whereType<String>().join(' - ');

    return Exception(
      'Network Error: ${details.isEmpty ? 'sin detalle' : details}',
    );
  }
}
