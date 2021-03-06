// Copyright (c) 2017, rinukkusu. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of spotify;

class Artists extends EndpointPaging {
  @override
  String get _path => 'v1/artists';

  Artists(SpotifyApiBase api) : super(api);

  Future<Artist> get(String artistId) async {
    var jsonString = await _api._get('$_path/$artistId');

    if (jsonString == "error") return null;

    var map = json.decode(jsonString);

    return Artist.fromJson(map);
  }

  //Max 50 ids for request
  Future<List<Artist>> getMultipleArtists(List<String> artistsId) async {
    String ids = artistsId.join(',');
    String path = '$_path/?ids=$ids';
    var jsonString = await _api._get(path);

    if (jsonString == "error") return [];

    var map = json.decode(jsonString);

    List<dynamic> artists = map["artists"].map((e) => Artist.fromJson(e)).toList();
    artists.removeWhere((element) => element.id == "");

    return List<Artist>.from(artists);
  }

  Future<Iterable<Track>> getTopTracks(String artistId, String countryCode) async {
    var jsonString = await _api._get('$_path/$artistId/top-tracks?country=$countryCode');

    if (jsonString == "error") return [];

    var map = json.decode(jsonString);

    var topTracks = map['tracks'] as Iterable<dynamic>;
    return topTracks.map((m) => Track.fromJson(m));
  }

  Future<Iterable<Artist>> getRelatedArtists(String artistId) async {
    var jsonString = await _api._get('$_path/$artistId/related-artists');

    if (jsonString == "error") return [];

    var map = json.decode(jsonString);

    var relatedArtists = map['artists'] as Iterable<dynamic>;
    return relatedArtists.map((m) => Artist.fromJson(m));
  }

  Future<Iterable<Artist>> list(Iterable<String> artistIds) async {
    var jsonString = await _api._get('$_path?ids=${artistIds.join(',')}');

    if (jsonString == "error") return [];

    var map = json.decode(jsonString);

    var artistsMap = map['artists'] as Iterable<dynamic>;
    return artistsMap.map((m) => Artist.fromJson(m));
  }

  Future<Iterable<Artist>> relatedArtists(String artistId) async {
    var jsonString = await _api._get('$_path/$artistId/related-artists');

    if (jsonString == "error") return [];
    
    var map = json.decode(jsonString);

    var artistsMap = map['artists'] as Iterable<dynamic>;
    return artistsMap.map((m) => Artist.fromJson(m));
  }

  /// [includeGroups] - A comma-separated list of keywords that will be used to
  /// filter the response. If not supplied, all album types will be returned.
  /// Valid values are: 'album', 'single', 'appears_on', 'compilation'
  ///
  /// [country] - An ISO 3166-1 alpha-2 country code or the string from_token.
  /// Supply this parameter to limit the response to one particular geographical
  /// market. For example, for albums available in Sweden: country=SE.
  /// If not given, results will be returned for all countries and you are
  /// likely to get duplicate results per album, one for each country in which
  /// the album is available!
  Pages<Album> albums(
    String artistId, {
    String country,
    List<String> includeGroups,
  }) {
    final _includeGroups = includeGroups == null ? null : includeGroups.join(',');
    final query = _buildQuery({'include_groups': _includeGroups, 'country': country});
    return _getPages('$_path/$artistId/albums?$query', (json) => Album.fromJson(json));
  }
}
