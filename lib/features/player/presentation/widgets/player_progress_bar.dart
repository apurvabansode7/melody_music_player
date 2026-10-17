import 'package:flutter/material.dart';
import 'package:melody_music_player/constants/app_colors.dart';
import 'package:melody_music_player/utils/formatter.dart';

class PlayerProgressBar extends StatefulWidget {
  const PlayerProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  State<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends State<PlayerProgressBar> {
  /// Set while the user is dragging. The real seek happens on release.
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.duration.inMilliseconds.toDouble();
    final canSeek = totalMs > 0;
    final maxMs = canSeek ? totalMs : 1.0;

    final currentMs = (_dragMs ?? widget.position.inMilliseconds.toDouble())
        .clamp(0.0, maxMs)
        .toDouble();

    final shownPosition = Duration(milliseconds: currentMs.round());

    return Column(
      children: [
        Slider(
          value: currentMs,
          max: maxMs,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.divider,
          onChanged:
              canSeek ? (value) => setState(() => _dragMs = value) : null,
          onChangeEnd: canSeek
              ? (value) {
                  widget.onSeek(Duration(milliseconds: value.round()));
                  setState(() => _dragMs = null);
                }
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeLabel(formatDuration(shownPosition)),
              _TimeLabel(formatDuration(widget.duration)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    );
  }
}