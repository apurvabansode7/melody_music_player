import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:melody_music_player/core/network/api_exception.dart';
import 'package:melody_music_player/features/track/data/repository/track_repository.dart';
import 'package:melody_music_player/features/track/presentation/bloc/track_event.dart';
import 'package:melody_music_player/features/track/presentation/bloc/track_state.dart';


class TracksBloc extends Bloc<TracksEvent, TracksState> {
  TracksBloc(this._repository) : super(const TracksState()) {
    on<TracksRequested>(_onRequested, transformer: droppable());
    // restartable + delay = debounce. A new keystroke cancels the wait.
    on<TracksSearchChanged>(_onSearchChanged, transformer: restartable());
    on<TracksNextPageRequested>(_onNextPageRequested, transformer: droppable());
  }

  final TrackRepository _repository;

  static const Duration _searchDebounce = Duration(milliseconds: 400);

  /// Incremented every time the first page is (re)loaded. A response is
  /// applied only if its generation is still current, so a slow request
  /// from an old query or an old list can never overwrite newer results.
  int _generation = 0;

  Future<void> _onRequested(
    TracksRequested event,
    Emitter<TracksState> emit,
  ) {
    // Refresh keeps the current list visible while reloading.
    final hasItems = state.tracks.isNotEmpty;
    return _loadFirstPage(emit, query: state.query, clearList: !hasItems);
  }

  Future<void> _onSearchChanged(
  TracksSearchChanged event,
  Emitter<TracksState> emit,
) async {
  // Invalidate in-flight pagination immediately, not after the debounce.
  _generation++;
  await Future<void>.delayed(_searchDebounce);
  await _loadFirstPage(
    emit,
    query: event.query.trim(),
    clearList: true,
  );
}

  Future<void> _onNextPageRequested(
    TracksNextPageRequested event,
    Emitter<TracksState> emit,
  ) async {
    // Guard against duplicate and pointless requests.
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.status != TracksStatus.success) {
      return;
    }

    // Capture what this request is for. The offset and query must match
    // the list when the response arrives, or the page is stale.
    final generation = _generation;
    final offset = state.tracks.length;
    final query = state.query;

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final more = await _repository.fetchTracks(
        offset: offset,
        query: query,
      );
      if (generation != _generation) return;

      emit(state.copyWith(
        tracks: [...state.tracks, ...more],
        hasMore: more.length == TrackRepository.pageSize,
        isLoadingMore: false,
      ));
    } catch (error) {
      if (generation != _generation) return;

      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: _messageFrom(error),
      ));
    }
  }

  Future<void> _loadFirstPage(
    Emitter<TracksState> emit, {
    required String query,
    required bool clearList,
  }) async {
    final generation = ++_generation;

    emit(state.copyWith(
      status: TracksStatus.loading,
      query: query,
      tracks: clearList ? const [] : state.tracks,
      hasMore: true,
      isLoadingMore: false,
      clearError: true,
    ));

    try {
      final tracks = await _repository.fetchTracks(query: query);
      if (generation != _generation) return;

      emit(state.copyWith(
        status: TracksStatus.success,
        tracks: tracks,
        hasMore: tracks.length == TrackRepository.pageSize,
      ));
    } catch (error) {
      if (generation != _generation) return;

      emit(state.copyWith(
        status: TracksStatus.failure,
        errorMessage: _messageFrom(error),
      ));
    }
  }

  String _messageFrom(Object error) {
    return error is ApiException ? error.message : 'Something went wrong.';
  }
}