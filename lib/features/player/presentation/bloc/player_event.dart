import 'package:equatable/equatable.dart';
import 'package:melody_music_player/core/audio/audio_player_service.dart';
import 'package:melody_music_player/features/track/data/model/track_model.dart';

sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

// ---- Events from the UI ----

/// Play the track at [index] in [queue]. The queue is the list the track
/// was chosen from, so next and previous move through it.
final class PlayerTrackRequested extends PlayerEvent {
  const PlayerTrackRequested(this.queue, this.index);

  final List<TrackModel> queue;
  final int index;

  @override
  List<Object?> get props => [queue, index];
}

final class PlayerToggled extends PlayerEvent {
  const PlayerToggled();
}

final class PlayerNextRequested extends PlayerEvent {
  const PlayerNextRequested();
}

final class PlayerPreviousRequested extends PlayerEvent {
  const PlayerPreviousRequested();
}

final class PlayerSeeked extends PlayerEvent {
  const PlayerSeeked(this.position);

  final Duration position;

  @override
  List<Object?> get props => [position];
}


final class PlayerPlaybackChanged extends PlayerEvent {
  const PlayerPlaybackChanged(this.snapshot);

  final PlaybackSnapshot snapshot;

  @override
  List<Object?> get props => [snapshot];
}

final class PlayerPositionChanged extends PlayerEvent {
  const PlayerPositionChanged(this.position);

  final Duration position;

  @override
  List<Object?> get props => [position];
}

final class PlayerDurationChanged extends PlayerEvent {
  const PlayerDurationChanged(this.duration);

  final Duration duration;

  @override
  List<Object?> get props => [duration];
}