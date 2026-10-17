import 'package:flutter/material.dart';
import 'package:melody_music_player/constants/app_colors.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AppSnackbar {
  AppSnackbar._();

  static void show(String message, {Color? backgroundColor}) {
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static void success(String message) =>
      show(message, backgroundColor: AppColors.success);

  static void error(String message) =>
      show(message, backgroundColor: AppColors.error);
}