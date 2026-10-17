import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:melody_music_player/core/audio/audio_player_service.dart';
import 'package:melody_music_player/core/services/api_services.dart';
import 'package:melody_music_player/core/storage/cache_store.dart';
import 'package:melody_music_player/core/theme/app_theme.dart';
import 'package:melody_music_player/features/player/presentation/bloc/player_bloc.dart';
import 'package:melody_music_player/features/splash/presentation/screens/splash_screen.dart';
import 'package:melody_music_player/features/track/data/repository/track_repository.dart';
import 'package:melody_music_player/utils/app_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

//  await dotenv.load(fileName: '.env');
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Could not load .env: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    // Dependency injection. Everything is created once here.
    RepositoryProvider<TrackRepository>(
      create: (_) => TrackRepository(ApiService(), CacheStore(prefs)),
      child: BlocProvider<PlayerBloc>(
        // PlayerBloc lives at the root so the mini player works everywhere.
        create: (_) => PlayerBloc(AudioPlayerService()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Melody Music Player',
          theme: AppTheme.dark,
          scaffoldMessengerKey: scaffoldMessengerKey,
          home: const SplashScreen(),
        );
      },
    );
  }
}