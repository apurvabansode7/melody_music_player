import 'package:dio/dio.dart';
import 'package:melody_music_player/constants/api_constants.dart';
import 'package:melody_music_player/core/network/api_exception.dart';

class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() => Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: const {'Accept': 'application/json'},
        ),
      );

  /// The single GET entry point. Adds the client ID and format to every
  /// request and returns the decoded JSON object.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        endpoint,
        queryParameters: {
          'client_id': ApiConstants.clientId,
          'format': 'json',
          ...?queryParameters,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ApiException('Unexpected response format.');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(
        _messageFor(e),
        statusCode: e.response?.statusCode,
        isNetworkError: _isNetworkError(e),
      );
    }
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  String _messageFor(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}).';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}