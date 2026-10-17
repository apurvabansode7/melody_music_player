import 'package:equatable/equatable.dart';
import 'package:melody_music_player/features/track/data/model/track_model.dart';

enum PlaybackStatus { idle, loading, ready, error }

final class PlayerState extends Equatable {
  const PlayerState({
    this.queue = const [],
    this.currentIndex = -1,
    this.status = PlaybackStatus.idle,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
  });

  final List<TrackModel> queue;
  final int currentIndex;
  final PlaybackStatus status;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final String? errorMessage;

  bool get hasTrack => currentIndex >= 0 && currentIndex < queue.length;
  TrackModel? get currentTrack => hasTrack ? queue[currentIndex] : null;
  bool get hasNext => currentIndex < queue.length - 1;
  bool get hasPrevious => currentIndex > 0;

  /// 0.0 to 1.0, used by the mini player's progress line.
  double get progress {
    if (duration.inMilliseconds == 0) return 0;
    final value = position.inMilliseconds / duration.inMilliseconds;
    return value.clamp(0.0, 1.0).toDouble();
  }

  PlayerState copyWith({
    List<TrackModel>? queue,
    int? currentIndex,
    PlaybackStatus? status,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlayerState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      status: status ?? this.status,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        queue,
        currentIndex,
        status,
        isPlaying,
        isBuffering,
        position,
        duration,
        errorMessage,
      ];
}