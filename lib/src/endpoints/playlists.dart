// Copyright (c) 2017, chances. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of spotify;

class Playlists extends EndpointPaging {
  @override
  String get _path => 'v1/browse';

  Playlists(SpotifyApiBase api) : super(api);

  Future<Playlist> get(String playlistId) async {
    return Playlist.fromJson(jsonDecode(await _api._get('v1/playlists/$playlistId')));
  }

  Pages<PlaylistSimple> get featured {
    return _getPages('$_path/featured-playlists', (json) => PlaylistSimple.fromJson(json), 'playlists', (json) => PlaylistsFeatured.fromJson(json));
  }

  Pages<PlaylistSimple> get me {
    return _getPages('v1/me/playlists', (json) => PlaylistSimple.fromJson(json));
  }

  /// [playlistId] - the Spotify playlist ID
  Pages<Track> getTracksByPlaylistId(playlistId) {
    return _getPages('v1/playlists/$playlistId/tracks', (json) => Track.fromJson(json['track']));
  }

  /// [userId] - the Spotify user ID
  ///
  /// [playlistName] - the name of the new playlist
  Future<Playlist> createPlaylist(String userId, String playlistName) async {
    final url = 'v1/users/$userId/playlists';
    final playlistJson = await _api._post(url, jsonEncode({'name': playlistName}));
    return await Playlist.fromJson(jsonDecode(playlistJson));
  }

  /// [trackUri] - the Spotify track uri (i.e spotify:track:4iV5W9uYEdYUVa79Axb7Rh)
  ///
  /// [playlistId] - the playlist ID
  Future<Null> addTrack(String trackUri, String playlistId) async {
    final url = 'v1/playlists/$playlistId/tracks';
    await _api._post(
        url,
        jsonEncode({
          'uris': [trackUri]
        }));
  }

  /// [trackUris] - the Spotify track uris
  /// (i.e each list item in the format of "spotify:track:4iV5W9uYEdYUVa79Axb7Rh")
  ///
  /// [playlistId] - the playlist ID
  Future<Null> addTracks(List<String> trackUris, String playlistId) async {
    final url = 'v1/playlists/$playlistId/tracks';
    await _api._post(url, jsonEncode({'uris': trackUris}));
  }

  Future<Null> removeTrack(String trackUri, String playlistId, [List<int> positions]) async {
    final url = 'v1/playlists/$playlistId/tracks';
    final track = <String, dynamic>{'uri': trackUri};
    if (positions != null) {
      track['positions'] = positions;
    }

    final body = jsonEncode({
      'tracks': [track]
    });
    await _api._delete(url, body);
  }

  /// [country] - a country: an ISO 3166-1 alpha-2 country code. Provide this
  /// parameter to ensure that the category exists for a particular country.
  ///
  /// [locale] - the desired language, consisting of an ISO 639-1 language code
  /// and an ISO 3166-1 alpha-2 country code, joined by an underscore. For
  /// example: es_MX, meaning "Spanish (Mexico)". Provide this parameter if you
  /// want the category strings returned in a particular language. Note that,
  /// if locale is not supplied, or if the specified language is not available,
  /// the category strings returned will be in the Spotify default language
  /// (American English).
  ///
  /// [categoryId] - the Spotify category ID for the category.
  Pages<PlaylistSimple> getByCategoryId(String categoryId, {String country, String locale}) {
    final query = _buildQuery({'country': country, 'locale': locale});

    return _getPages('$_path/categories/$categoryId/playlists?$query', (json) => PlaylistSimple.fromJson(json), 'playlists',
        (json) => PlaylistsFeatured.fromJson(json));
  }

  Future<bool> modifyPlaylistDetails({String id, String name, String description, bool isPublic, bool isCollaborative}) async {
    String body = jsonEncode(<String, dynamic>{
      'name': name,
      'public': isPublic,
      'collaborative': isCollaborative,
    });
    String result = await _api._put('v1/playlists/$id', body);

    return result != "error";
  }

  Future<bool> modifyPlaylistImage({String id, String image}) async {
    String result = await _api._putImage('v1/playlists/$id/images', image);

    return result != "error";
  }
}
