import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/user_defaults.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        responseType: ResponseType.json,
      ),
    );
  }

  static final ApiClient _instance = ApiClient._();

  factory ApiClient() => _instance;

  late final Dio _dio;

  Future<Response<dynamic>> request({
    required String path,
    required String method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool withHeader = true,
    Map<String, String>? extraHeaders,
    bool isFormData = false,
    Map<String, File>? files,
  }) async {
    try {
      dynamic payload = body;
      if (isFormData) {
        final fields = Map<String, dynamic>.from(body as Map<String, dynamic>? ?? {});
        if (files != null) {
          for (final entry in files.entries) {
            fields[entry.key] = await MultipartFile.fromFile(entry.value.path);
          }
        }
        payload = FormData.fromMap(fields);
      }

      final response = await _dio.request<dynamic>(
        path,
        data: payload,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: _buildHeaders(
            withHeader,
            isFormData
                ? <String, String>{
                    'Content-Type': 'multipart/form-data',
                    ...?extraHeaders,
                  }
                : extraHeaders,
          ),
        ),
      );
      return response;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool withHeader = true,
    Map<String, String>? extraHeaders,
  }) {
    return request(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
      withHeader: withHeader,
      extraHeaders: extraHeaders,
    );
  }

  Future<Response<dynamic>> getWithHeader(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
  }) {
    return get(
      path,
      queryParameters: queryParameters,
      withHeader: true,
      extraHeaders: extraHeaders,
    );
  }

  Future<Response<dynamic>> getWithoutHeader(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
  }) {
    return get(
      path,
      queryParameters: queryParameters,
      withHeader: false,
      extraHeaders: extraHeaders,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic body,
    bool withHeader = true,
    Map<String, String>? extraHeaders,
  }) {
    return request(
      path: path,
      method: 'POST',
      body: body,
      withHeader: withHeader,
      extraHeaders: extraHeaders,
    );
  }

  Future<Response<dynamic>> postWithHeader(
    String path, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) {
    return post(path, body: body, withHeader: true, extraHeaders: extraHeaders);
  }

  Future<Response<dynamic>> postWithoutHeader(
    String path, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) {
    return post(path, body: body, withHeader: false, extraHeaders: extraHeaders);
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic body,
    bool withHeader = true,
    Map<String, String>? extraHeaders,
  }) {
    return request(
      path: path,
      method: 'PUT',
      body: body,
      withHeader: withHeader,
      extraHeaders: extraHeaders,
    );
  }

  Future<Response<dynamic>> putWithHeader(
    String path, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) {
    return put(path, body: body, withHeader: true, extraHeaders: extraHeaders);
  }

  Future<Response<dynamic>> putWithoutHeader(
    String path, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) {
    return put(path, body: body, withHeader: false, extraHeaders: extraHeaders);
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic body,
    bool withHeader = true,
    Map<String, String>? extraHeaders,
  }) {
    return request(
      path: path,
      method: 'PATCH',
      body: body,
      withHeader: withHeader,
      extraHeaders: extraHeaders,
    );
  }

  Future<Response<dynamic>> patchWithHeader(
    String path, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) {
    return patch(path, body: body, withHeader: true, extraHeaders: extraHeaders);
  }

  Future<Response<dynamic>> patchWithoutHeader(
    String path, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) {
    return patch(path, body: body, withHeader: false, extraHeaders: extraHeaders);
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic body,
    bool withHeader = true,
    Map<String, String>? extraHeaders,
  }) {
    return request(
      path: path,
      method: 'DELETE',
      body: body,
      withHeader: withHeader,
      extraHeaders: extraHeaders,
    );
  }

  Future<Response<dynamic>> deleteWithHeader(
    String path, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) {
    return delete(path, body: body, withHeader: true, extraHeaders: extraHeaders);
  }

  Future<Response<dynamic>> deleteWithoutHeader(
    String path, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) {
    return delete(path, body: body, withHeader: false, extraHeaders: extraHeaders);
  }

  Future<Response<dynamic>> postFormData(
    String path, {
    required Map<String, dynamic> fields,
    Map<String, File>? files,
    bool withHeader = true,
    Map<String, String>? extraHeaders,
  }) {
    return request(
      path: path,
      method: 'POST',
      body: fields,
      files: files,
      withHeader: withHeader,
      extraHeaders: extraHeaders,
      isFormData: true,
    );
  }

  Future<Response<dynamic>> postFormDataWithHeader(
    String path, {
    required Map<String, dynamic> fields,
    Map<String, File>? files,
    Map<String, String>? extraHeaders,
  }) {
    return postFormData(
      path,
      fields: fields,
      files: files,
      withHeader: true,
      extraHeaders: extraHeaders,
    );
  }

  Future<Response<dynamic>> postFormDataWithoutHeader(
    String path, {
    required Map<String, dynamic> fields,
    Map<String, File>? files,
    Map<String, String>? extraHeaders,
  }) {
    return postFormData(
      path,
      fields: fields,
      files: files,
      withHeader: false,
      extraHeaders: extraHeaders,
    );
  }

  Future<Response<dynamic>> putFormData(
    String path, {
    required Map<String, dynamic> fields,
    Map<String, File>? files,
    bool withHeader = true,
    Map<String, String>? extraHeaders,
  }) {
    return request(
      path: path,
      method: 'PUT',
      body: fields,
      files: files,
      withHeader: withHeader,
      extraHeaders: extraHeaders,
      isFormData: true,
    );
  }

  Future<Response<dynamic>> patchFormData(
    String path, {
    required Map<String, dynamic> fields,
    Map<String, File>? files,
    bool withHeader = true,
    Map<String, String>? extraHeaders,
  }) {
    return request(
      path: path,
      method: 'PATCH',
      body: fields,
      files: files,
      withHeader: withHeader,
      extraHeaders: extraHeaders,
      isFormData: true,
    );
  }

  Map<String, String> _buildHeaders(
    bool withHeader,
    Map<String, String>? extraHeaders,
  ) {
    final headers = <String, String>{
      'Accept': 'application/json',
      ...?extraHeaders,
    };

    if (withHeader) {
      final token = UserDefaults.token;
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  ApiException _mapDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data.toString() ?? error.message ?? 'Unknown API error';
    return ApiException(message, statusCode: statusCode);
  }
}
