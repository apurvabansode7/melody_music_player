import 'package:just_audio/just_audio.dart';

/// Playback flags, derived from just_audio's PlayerState.
typedef PlaybackSnapshot = ({
  bool isPlaying,
  bool isBuffering,
  bool isCompleted,
});

class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;

  Stream<PlaybackSnapshot> get playbackStream {
    return _player.playerStateStream.map((state) {
      final processing = state.processingState;
      return (
        isPlaying: state.playing,
        isBuffering: processing == ProcessingState.loading ||
            processing == ProcessingState.buffering,
        isCompleted: processing == ProcessingState.completed,
      );
    });
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Future<void> setUrl(String url) => _player.setUrl(url);

  /// Completes only when playback ends or pauses. Callers should not await
  /// it; use unawaited(...) instead.
  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> dispose() => _player.dispose();
}