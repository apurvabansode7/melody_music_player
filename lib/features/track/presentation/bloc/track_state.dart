import 'package:equatable/equatable.dart';
import 'package:melody_music_player/features/track/data/model/track_model.dart';

enum TracksStatus { initial, loading, success, failure }

final class TracksState extends Equatable {
  const TracksState({
    this.status = TracksStatus.initial,
    this.tracks = const [],
    this.query = '',
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final TracksStatus status;
  final List<TrackModel> tracks;
  final String query;

  /// False once a page comes back smaller than the page size.
  final bool hasMore;

  final bool isLoadingMore;
  final String? errorMessage;

  bool get isEmpty => status == TracksStatus.success && tracks.isEmpty;

  TracksState copyWith({
    TracksStatus? status,
    List<TrackModel>? tracks,
    String? query,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TracksState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        tracks,
        query,
        hasMore,
        isLoadingMore,
        errorMessage,
      ];
}