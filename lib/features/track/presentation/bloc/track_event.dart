import 'package:equatable/equatable.dart';

sealed class TracksEvent extends Equatable {
  const TracksEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load, or pull-to-refresh. Reloads the first page for the
/// current query.
final class TracksRequested extends TracksEvent {
  const TracksRequested();
}

/// Fired on every keystroke. The bloc debounces it.
final class TracksSearchChanged extends TracksEvent {
  const TracksSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Fired when the user scrolls near the bottom of the list.
final class TracksNextPageRequested extends TracksEvent {
  const TracksNextPageRequested();
}