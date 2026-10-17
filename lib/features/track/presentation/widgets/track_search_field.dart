import 'package:flutter/material.dart';
import 'package:melody_music_player/constants/app_colors.dart';

class TrackSearchField extends StatelessWidget {
  const TrackSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      cursorColor: AppColors.primary,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration:const InputDecoration(
        hintText: 'Search tracks',
        hintStyle:  TextStyle(color: AppColors.textSecondary),
        prefixIcon:  Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:  EdgeInsets.symmetric(vertical: 14),
        border:  OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}