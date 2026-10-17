
// import 'package:melody_music_player/core/services/api_services.dart';
// import 'package:melody_music_player/core/storage/cache_store.dart';
// import 'package:melody_music_player/features/track/data/model/track_model.dart';


// class TrackRepository {
//   TrackRepository(this._apiService, CacheStore cacheStore);

//   final ApiService _apiService;

//   static const int pageSize = 20;

//   Future<List<TrackModel>> fetchTracks({
//     int offset = 0,
//     String query = '',
//   }) async {
//     final data = await _apiService.get(
//       '/tracks/',
//       queryParameters: {
//         'limit': pageSize,
//         'offset': offset,
//         if (query.trim().isNotEmpty) 'namesearch': query.trim(),
//       },
//     );

//     if (data['headers'] is Map &&
//         (data['headers']['status'] != 'success')) {
//       final message =
//           data['headers']['error_message']?.toString();
//       throw Exception(
//         message == null || message.isEmpty
//             ? 'Jamendo API request failed.'
//             : message,
//       );
//     }

//     final results = data['results'];

//     if (results is! List) {
//       throw const FormatException(
//         'The API response does not contain a valid results list.',
//       );
//     }

//     return results
//         .whereType<Map<String, dynamic>>()
//         .map(TrackModel.fromJson)
//         .toList();
//   }
// }
import 'package:melody_music_player/core/network/api_exception.dart';
import 'package:melody_music_player/core/services/api_services.dart';
import 'package:melody_music_player/core/storage/cache_store.dart';
import 'package:melody_music_player/features/track/data/model/track_model.dart';

class TrackRepository {
  TrackRepository(this._apiService, this._cache);

  final ApiService _apiService;
  final CacheStore _cache;

  static const int pageSize = 20;

  /// Fetches one page of tracks, optionally filtered by name.
  /// Successful pages are cached. If the device is offline, the cached
  /// page for the same query and offset is returned instead.
  Future<List<TrackModel>> fetchTracks({
    int offset = 0,
    String query = '',
  }) async {
    final term = query.trim();
    final cacheKey = 'tracks|q=$term|offset=$offset';

    try {
      final results = await _getResults('/tracks/', {
        'limit': pageSize,
        'offset': offset,
        if (term.isNotEmpty) 'namesearch': term,
      });

      await _cache.saveList(cacheKey, results);
      return results.map(TrackModel.fromJson).toList();
    } on ApiException catch (e) {
      final cached = e.isNetworkError ? _cache.readList(cacheKey) : null;
      if (cached == null) rethrow;
      return cached.map(TrackModel.fromJson).toList();
    }
  }

  /// Calls the API and validates Jamendo's response envelope.
  Future<List<Map<String, dynamic>>> _getResults(
    String endpoint,
    Map<String, dynamic> params,
  ) async {
    final data = await _apiService.get(endpoint, queryParameters: params);

    final headers = data['headers'];
    if (headers is Map && headers['status'] != 'success') {
      final message = headers['error_message']?.toString();
      throw ApiException(
        (message == null || message.isEmpty)
            ? 'Jamendo API request failed.'
            : message,
      );
    }

    final results = data['results'];
    if (results is! List) {
      throw const ApiException('Invalid response: missing results list.');
    }

    return results.whereType<Map<String, dynamic>>().toList();
  }
}