import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melody_music_player/constants/app_colors.dart';
import 'package:melody_music_player/core/widgets/artwork.dart';
import 'package:melody_music_player/core/widgets/status_message.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_bloc.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_event.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_state.dart';
import 'package:melody_music_player/features/player/presentation/widgets/player_progress_bar.dart';
import 'package:melody_music_player/features/player/presentation/widgets/players_controls.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final track = state.currentTrack;
        final bloc = context.read<PlayerBloc>();

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Now Playing',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: track == null
              ? const StatusMessage(
                  icon: Icons.music_off_rounded,
                  message: 'Nothing is playing.',
                )
              : SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Artwork scales with the screen, capped for tablets.
                      final artSize =
                          math.min(constraints.maxWidth * 0.8, 420.0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            SizedBox(
                              width: artSize,
                              height: artSize,
                              child: Artwork(
                                url: track.imageUrl,
                                borderRadius: 24,
                                iconSize: 80,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              track.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              track.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            PlayerProgressBar(
                              position: state.position,
                              duration: state.duration,
                              onSeek: (position) =>
                                  bloc.add(PlayerSeeked(position)),
                            ),
                            const SizedBox(height: 16),
                            PlayerControls(
                              isPlaying: state.isPlaying,
                              isBuffering: state.isBuffering,
                              hasPrevious: state.hasPrevious,
                              hasNext: state.hasNext,
                              onPrevious: () =>
                                  bloc.add(const PlayerPreviousRequested()),
                              onToggle: () =>
                                  bloc.add(const PlayerToggled()),
                              onNext: () =>
                                  bloc.add(const PlayerNextRequested()),
                            ),
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                state.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ],
                            const Spacer(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}