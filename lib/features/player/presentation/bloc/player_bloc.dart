

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:melody_music_player/core/audio/audio_player_service.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_event.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc(this._audio) : super(const PlayerState()) {
    // Track changes go through one restartable handler. If the user taps
    // quickly, the older load is cancelled and only the latest one plays.
    on<PlayerTrackRequested>(_onTrackRequested, transformer: restartable());
    on<PlayerToggled>(_onToggled, transformer: droppable());
    on<PlayerNextRequested>(_onNext);
    on<PlayerPreviousRequested>(_onPrevious);
    on<PlayerSeeked>(_onSeeked);
    on<PlayerPlaybackChanged>(_onPlaybackChanged);
    on<PlayerPositionChanged>(
      (event, emit) => emit(state.copyWith(position: event.position)),
    );
    on<PlayerDurationChanged>(
      (event, emit) => emit(state.copyWith(duration: event.duration)),
    );

    // Bridge the audio streams into events. The UI never talks to
    // just_audio directly.
    _subscriptions = [
      _audio.playbackStream.listen((s) => add(PlayerPlaybackChanged(s))),
      _audio.positionStream.listen((p) => add(PlayerPositionChanged(p))),
      _audio.durationStream
          .listen((d) => add(PlayerDurationChanged(d ?? Duration.zero))),
    ];
  }

  final AudioPlayerService _audio;
  late final List<StreamSubscription<dynamic>> _subscriptions;

  Future<void> _onTrackRequested(
    PlayerTrackRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (event.index < 0 || event.index >= event.queue.length) return;

    final track = event.queue[event.index];

    emit(state.copyWith(
      queue: event.queue,
      currentIndex: event.index,
      status: PlaybackStatus.loading,
      isPlaying: false,
      isBuffering: true,
      position: Duration.zero,
      duration: Duration.zero,
      clearError: true,
    ));

    if (track.audioUrl.isEmpty) {
      emit(state.copyWith(
        status: PlaybackStatus.error,
        isBuffering: false,
        errorMessage: 'No audio available for "${track.name}".',
      ));
      return;
    }

    try {
      await _audio.setUrl(track.audioUrl);
      emit(state.copyWith(status: PlaybackStatus.ready, isBuffering: false));
      // Do not await: play() completes only when the track ends or pauses.
      unawaited(_audio.play());
    } on Exception {
      emit(state.copyWith(
        status: PlaybackStatus.error,
        isBuffering: false,
        isPlaying: false,
        errorMessage: 'Unable to play "${track.name}". Check your connection.',
      ));
    }
  }

  Future<void> _onToggled(
    PlayerToggled event,
    Emitter<PlayerState> emit,
  ) async {
    if (!state.hasTrack || state.status == PlaybackStatus.loading) return;

    // After an error, tapping play reloads the current track.
    if (state.status == PlaybackStatus.error) {
      add(PlayerTrackRequested(state.queue, state.currentIndex));
      return;
    }

    if (state.isPlaying) {
      await _audio.pause();
      return;
    }

    // Replay from the start if the track had finished.
    if (state.duration > Duration.zero && state.position >= state.duration) {
      await _audio.seek(Duration.zero);
    }
    unawaited(_audio.play());
  }

  void _onNext(PlayerNextRequested event, Emitter<PlayerState> emit) {
    if (!state.hasNext) return;
    add(PlayerTrackRequested(state.queue, state.currentIndex + 1));
  }

  void _onPrevious(PlayerPreviousRequested event, Emitter<PlayerState> emit) {
    if (!state.hasPrevious) return;
    add(PlayerTrackRequested(state.queue, state.currentIndex - 1));
  }

  Future<void> _onSeeked(PlayerSeeked event, Emitter<PlayerState> emit) async {
    if (state.status != PlaybackStatus.ready) return;
    emit(state.copyWith(position: event.position));
    await _audio.seek(event.position);
  }

  void _onPlaybackChanged(
    PlayerPlaybackChanged event,
    Emitter<PlayerState> emit,
  ) {
    final snapshot = event.snapshot;

    if (snapshot.isCompleted) {
      if (state.hasNext) {
        // Auto-advance to the next track in the queue.
        add(const PlayerNextRequested());
      } else {
        emit(state.copyWith(
          isPlaying: false,
          isBuffering: false,
          position: state.duration,
        ));
      }
      return;
    }

    emit(state.copyWith(
      isPlaying: snapshot.isPlaying,
      isBuffering: snapshot.isBuffering,
    ));
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _audio.dispose();
    return super.close();
  }
}