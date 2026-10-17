# Melody Music Player

A Flutter music player built on the [Jamendo API](https://developer.jamendo.com/v3.0). It supports browsing, debounced search, paginated loading with limit/offset, audio playback with a mini player and a Now Playing screen, and offline caching of track pages.

**APK:** [Download the latest release](https://github.com/[your-username]/melody_music_player/releases)

## Features

- Track listing with infinite scroll (limit/offset pagination)
- Debounced search using Jamendo's `namesearch` parameter
- Loading, error, empty, and end-of-list states
- Play, pause, previous, next, seek bar, duration, and live position
- Mini player and Now Playing screen, both synced to playback state
- Offline fallback: previously loaded track pages are shown when there is no network
- Responsive grid (2 to 5 columns depending on screen width)

## Requirements

- Flutter 3.22 or newer (Dart 3.3 or newer)
- Android device or emulator (Android 5.0 / API 21 or newer)
- A Jamendo client ID from [developer.jamendo.com](https://developer.jamendo.com)

## Setup

1. Clone the repository and install dependencies:

```bash
   git clone https://github.com/[your-username]/melody_music_player.git
   cd melody_music_player
   flutter pub get
```

2. Create your local environment file from the template:

```bash
   cp .env.example .env
```

3. Open `.env` and set your client ID:

```dotenv
   API_BASE_URL=https://api.jamendo.com/v3.0
   CLIENT_ID=your_jamendo_client_id
```

4. Run the app:

```bash
   flutter run
```

5. Build a release APK (optional):

```bash
   flutter build apk --release
```

   The output is at `build/app/outputs/flutter-apk/app-release.apk`.

## API configuration

The app reads its settings from `.env` at startup, through `flutter_dotenv`.

| Key | Purpose | Example |
|---|---|---|
| `API_BASE_URL` | Jamendo base URL | `https://api.jamendo.com/v3.0` |
| `CLIENT_ID` | Your Jamendo client ID | `your_jamendo_client_id` |

Every request includes `client_id` and `format=json`. Track listing uses:

```
GET /tracks/?client_id=...&format=json&limit=20&offset=0
```

Search adds the `namesearch` parameter:

```
GET /tracks/?client_id=...&format=json&namesearch={query}&limit=20&offset=0
```

**Security note:** `.env` is excluded from git and is never committed. Because it is bundled as a Flutter asset, the client ID is included in the compiled APK. Jamendo client IDs are intended for client applications, so this is expected for this project. Do not put secrets that must stay private (such as a server-side secret) in this file.

## Architecture

The project uses a feature-first layout with three layers per feature.

```
lib/
├── constants/          app colors, API configuration
├── core/
│   ├── audio/          AudioPlayerService (wraps just_audio)
│   ├── network/        ApiService (Dio), ApiException
│   ├── storage/        CacheStore (SharedPreferences)
│   ├── theme/          AppTheme
│   ├── utils/          formatters, responsive helpers, snackbar
│   └── widgets/        Artwork, StatusMessage (shared across features)
└── features/
    ├── splash/         splash screen
    ├── track/          listing and search
    │   ├── data/       TrackModel, TrackRepository
    │   └── presentation/  TracksBloc, screens, widgets
    └── player/         playback
        └── presentation/  PlayerBloc, screens, widgets
```

- **Presentation** contains screens and widgets. Widgets receive plain values and callbacks, so they can be reused and tested without a BLoC.
- **Data** contains the repository, which decides where data comes from (the network or the cache) and converts JSON into `TrackModel`.
- **Core** contains infrastructure that any feature can use: HTTP, the audio player, storage, and shared widgets. Only `AudioPlayerService` imports `just_audio`, and only `ApiService` talks to Dio.

Data flow:

```
UI → BLoC (events) → Repository → ApiService (Dio)
                        └──→ CacheStore (offline fallback)
UI ← BLoC (states) ←─┘

PlayerBloc → AudioPlayerService (just_audio)
          ↑ playback streams are converted into events
```

## State management

State management uses **flutter_bloc**.

- **Events** describe what happened: a search was typed, the user scrolled near the bottom, a track was tapped, play was pressed.
- **States** describe what the UI should show: status, the track list, `hasMore`, `isLoadingMore`, the error message, playback position, and whether audio is playing.
- **`TracksBloc`** manages listing and search. It uses:
  - `restartable` for search, so only the latest keystroke is applied after a 400 ms debounce.
  - `droppable` for pagination and refresh, so duplicate requests are ignored while one is running.
  - A generation counter, so a slow response for an old query or an old list is discarded instead of overwriting newer results.
- **`PlayerBloc`** is provided at the app root, so the mini player works on every screen. It converts audio-stream updates into events, so the UI always reflects the real playback state. Track changes use `restartable`, so fast taps load only the last track.
- Dependencies are created once in `main.dart` and passed down with `RepositoryProvider` and `BlocProvider`. BLoCs never create their own network or audio objects.

## Offline caching

Each successful track page is saved to `shared_preferences`, keyed by query and offset. If a request fails because the device has no connection, the cached page for the same query and offset is returned. Server errors are not hidden by the cache. Cover images are also cached on disk by `cached_network_image`.

## Known limitations

- Next and previous move through the tracks already loaded. Playback does not fetch new pages.
- Audio is not cached, so playback needs a connection.
- The cache has no expiry. A page stays cached until the same page is fetched again successfully.
- Only Android has been tested.

## Tests

```bash
flutter test
```

Current tests cover `TrackModel.fromJson`, its fallback values, and duration formatting.

## Project dependencies

`flutter_bloc`, `bloc_concurrency`, `equatable`, `dio`, `just_audio`, `cached_network_image`, `shared_preferences`, `flutter_dotenv`, `flutter_screenutil`.