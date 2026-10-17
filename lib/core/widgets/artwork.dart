import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:melody_music_player/constants/app_colors.dart';

/// Reusable cover image. Used by track cards, the mini player, and
/// Now Playing. Caches on disk and shows a placeholder while loading
/// or on error.
class Artwork extends StatelessWidget {
  const Artwork({
    super.key,
    required this.url,
    this.borderRadius = 12,
    this.iconSize = 40,
  });

  final String url;
  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox.expand(
        child: url.isEmpty
            ? _placeholder()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => _placeholder(),
                errorWidget: (_, __, ___) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.music_note_rounded,
        color: AppColors.accent,
        size: iconSize,
      ),
    );
  }
}