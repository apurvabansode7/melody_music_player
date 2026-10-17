import 'package:flutter/material.dart';
import 'package:melody_music_player/constants/app_colors.dart';
import 'package:melody_music_player/core/responsive/responsive.dart';
import 'package:melody_music_player/features/track/data/model/track_model.dart';
import 'package:melody_music_player/features/track/presentation/widgets/track_card.dart';

class TrackGrid extends StatelessWidget {
  const TrackGrid({
    super.key,
    required this.tracks,
    required this.isLoadingMore,
    required this.hasMore,
    required this.controller,
    required this.onRefresh,
    required this.onTrackTap,
    this.activeTrackId,
  });

  final List<TrackModel> tracks;
  final bool isLoadingMore;
  final bool hasMore;
  final ScrollController controller;
  final RefreshCallback onRefresh;
  final ValueChanged<int> onTrackTap;
  final String? activeTrackId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridColumns(context),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return TrackCard(
                  track: track,
                  isActive: track.id == activeTrackId,
                  onTap: () => onTrackTap(index),
                );
              },
            ),
          ),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
          if (!hasMore && !isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    "You've reached the end",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}