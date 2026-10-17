import 'package:flutter/material.dart';
import 'package:melody_music_player/constants/app_colors.dart';

/// Presentational only: receives values and callbacks, so it can be reused
/// and tested without a BLoC.
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isBuffering,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onToggle,
    required this.onNext,
  });

  final bool isPlaying;
  final bool isBuffering;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 40,
          color: AppColors.textPrimary,
          disabledColor: AppColors.divider,
          onPressed: hasPrevious ? onPrevious : null,
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 72,
          height: 72,
          child: Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onToggle,
              child: Center(
                child: isBuffering
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 40,
                        color: AppColors.textPrimary,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          iconSize: 40,
          color: AppColors.textPrimary,
          disabledColor: AppColors.divider,
          onPressed: hasNext ? onNext : null,
          icon: const Icon(Icons.skip_next_rounded),
        ),
      ],
    );
  }
}