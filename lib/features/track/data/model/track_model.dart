
class TrackModel {
  final String id;
  final String name;
  final String artistName;
  final String albumName;
  final String imageUrl;
  final String audioUrl;
  final int duration;

  const TrackModel({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.imageUrl,
    required this.audioUrl,
    required this.duration,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown track',
      artistName:
          json['artist_name']?.toString() ?? 'Unknown artist',
      albumName: json['album_name']?.toString() ?? '',
      imageUrl: json['image']?.toString() ?? '',
      audioUrl: json['audio']?.toString() ?? '',
      duration:
          int.tryParse(json['duration']?.toString() ?? '') ?? 0,
    );
  }
}
