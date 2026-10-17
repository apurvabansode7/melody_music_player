import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melody_music_player/constants/app_colors.dart';
import 'package:melody_music_player/core/widgets/status_message.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_bloc.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_event.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_state.dart';
import 'package:melody_music_player/features/player/presentation/widgets/mini_player.dart';
import 'package:melody_music_player/features/track/data/model/track_model.dart';
import 'package:melody_music_player/features/track/data/repository/track_repository.dart';
import 'package:melody_music_player/features/track/presentation/bloc/track_bloc.dart';
import 'package:melody_music_player/features/track/presentation/bloc/track_event.dart';
import 'package:melody_music_player/features/track/presentation/bloc/track_state.dart';
import 'package:melody_music_player/features/track/presentation/widgets/track_grid.dart';
import 'package:melody_music_player/features/track/presentation/widgets/track_search_field.dart';
import 'package:melody_music_player/utils/app_snackbar.dart';

class TracksScreen extends StatelessWidget {
  const TracksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The TracksBloc is scoped to this screen. It loads the first page
    // as soon as the screen is created.
    return BlocProvider(
      create: (context) => TracksBloc(context.read<TrackRepository>())
        ..add(const TracksRequested()),
      child: const _TracksView(),
    );
  }
}

class _TracksView extends StatefulWidget {
  const _TracksView();

  @override
  State<_TracksView> createState() => _TracksViewState();
}

class _TracksViewState extends State<_TracksView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Requests the next page when the user is within 300px of the bottom.
  /// The BLoC ignores the request if a page is already loading or there
  /// are no more pages.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<TracksBloc>().add(const TracksNextPageRequested());
    }
  }

  void _refresh() {
    context.read<TracksBloc>().add(const TracksRequested());
  }

  void _playTrack(List<TrackModel> queue, int index) {
    context.read<PlayerBloc>().add(PlayerTrackRequested(queue, index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TrackSearchField(
                onChanged: (query) => context
                    .read<TracksBloc>()
                    .add(TracksSearchChanged(query)),
              ),
            ),
            Expanded(
              child: BlocConsumer<TracksBloc, TracksState>(
                listenWhen: (previous, current) =>
                    current.errorMessage != null &&
                    current.errorMessage != previous.errorMessage,
                listener: (context, state) {
                  // Errors while the list is already visible, such as a
                  // failed "load more".
                  AppSnackbar.error(state.errorMessage!);
                },
                builder: (context, state) => _buildBody(state),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayerBar(),
    );
  }

  Widget _buildBody(TracksState state) {
    // Full-screen failure only when there is nothing to show.
    if (state.status == TracksStatus.failure && state.tracks.isEmpty) {
      return StatusMessage(
        icon: Icons.wifi_off_rounded,
        message: state.errorMessage ?? 'Something went wrong.',
        actionLabel: 'Try again',
        onAction: _refresh,
      );
    }

    if (state.status == TracksStatus.loading && state.tracks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.isEmpty) {
      return const StatusMessage(
        icon: Icons.music_off_rounded,
        message: 'No tracks found.',
      );
    }

    // Rebuild the grid only when the playing track changes, not on every
    // position tick from the audio stream.
    return BlocSelector<PlayerBloc, PlayerState, String?>(
      selector: (playerState) => playerState.currentTrack?.id,
      builder: (context, activeTrackId) => TrackGrid(
        tracks: state.tracks,
        isLoadingMore: state.isLoadingMore,
        hasMore: state.hasMore,
        controller: _scrollController,
        onRefresh: () async => _refresh(),
        onTrackTap: (index) => _playTrack(state.tracks, index),
        activeTrackId: activeTrackId,
      ),
    );
  }
}