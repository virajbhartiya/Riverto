class RecentlyPlayed {
  String title, url, image, album, artist, lyrics;
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'image': image,
      'album': album,
      'artist': artist,
      'lyrics': lyrics
    };
  }
}
