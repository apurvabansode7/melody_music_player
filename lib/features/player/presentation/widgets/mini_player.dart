import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melody_music_player/constants/app_colors.dart';
import 'package:melody_music_player/core/widgets/artwork.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_bloc.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_event.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_state.dart';
import 'package:melody_music_player/features/player/presentation/screens/now_playing_screen.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) return const SizedBox.shrink();

        final bloc = context.read<PlayerBloc>();

        return SafeArea(
          top: false,
          child: Material(
            color: AppColors.surface,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 2,
                    color: AppColors.primary,
                    backgroundColor: AppColors.divider,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Artwork(url: track.imageUrl, borderRadius: 10),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                track.artistName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          color: AppColors.textPrimary,
                          onPressed: () => bloc.add(const PlayerToggled()),
                          icon: state.isBuffering
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Icon(
                                  state.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 30,
                                ),
                        ),
                        IconButton(
                          color: AppColors.textPrimary,
                          disabledColor: AppColors.divider,
                          onPressed: state.hasNext
                              ? () => bloc.add(const PlayerNextRequested())
                              : null,
                          icon: const Icon(Icons.skip_next_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}