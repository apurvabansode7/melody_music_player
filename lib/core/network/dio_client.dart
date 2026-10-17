import 'package:dio/dio.dart';
import 'package:melody_music_player/constants/api_constants.dart';

class DioClient {
  DioClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      queryParameters: {
        'client_id': ApiConstants.clientId,
        'format': 'json',
      },
    ),
  );
}
