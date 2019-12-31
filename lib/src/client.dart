import 'package:http/http.dart' as http;

import 'caching/cache_provider.dart';
import 'caching/memory_cache.dart';

const _apiBase = 'https://www.thebluealliance.com/api/v3';

final _maxAgeRegex = RegExp('max-age=(\\d+)');

/// An [http.Client] with special behavior for The Blue Alliance API calls.
///
/// The provided key will be added as the `X-TBA-Auth-Key` header for all
/// requests made to the TBA API. Resources may also be served from the cache.
class TbaClient extends http.BaseClient {
  final String _key;
  final TbaCacheProvider _cache;
  final http.Client _inner;

  /// Constructs a [TbaClient] using the given key.
  ///
  /// [cache] defaults to a new [MemoryCache].
  ///
  /// [inner] defaults to a new [http.Client].
  ///
  /// **Do not include your API key in your source code!** Read it from an
  /// environment variable or file ignored by source control.
  TbaClient(this._key, {TbaCacheProvider cache, http.Client inner})
      : _cache = cache ?? MemoryCache(),
        _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!request.url.toString().startsWith(_apiBase)) {
      return _inner.send(request);
    } else {
      request.headers['X-TBA-Auth-Key'] = _key;
      var resource = request.url.toString().substring(_apiBase.length);

      if (await _cache.isCached(resource)) {
        if (DateTime.now().isBefore(await _cache.cacheUntil(resource))) {
          return http.StreamedResponse(
              Stream.fromFuture(_cache.getCached(resource)), 304);
        }

        request.headers['If-Modified-Since'] =
            await _cache.lastModified(resource);
      }

      var response = await _inner.send(request);
      if (response.statusCode == 304) {
        var lastModified = response.headers['last-modified'];

        var maxAge = 0;
        if (response.headers.containsKey('cache-control')) {
          var maxAgeMatch =
              _maxAgeRegex.firstMatch(response.headers['cache-control']);
          if (maxAgeMatch != null) {
            maxAge = int.parse(maxAgeMatch.group(1));
          }
        }
        var cacheUntil = DateTime.now().add(Duration(seconds: maxAge));

        var body = await _cache.getCached(resource);

        await _cache.cache(resource, body, lastModified, cacheUntil);

        return http.StreamedResponse(Stream.value(body), 304);
      } else if (response.statusCode != 200) {
        return response;
      } else {
        var lastModified = response.headers['last-modified'];

        var maxAge = 0;
        if (response.headers.containsKey('cache-control')) {
          var maxAgeMatch =
              _maxAgeRegex.firstMatch(response.headers['cache-control']);
          if (maxAgeMatch != null) {
            maxAge = int.parse(maxAgeMatch.group(1));
          }
        }
        var cacheUntil = DateTime.now().add(Duration(seconds: maxAge));

        var body = await response.stream.toBytes();

        await _cache.cache(resource, body, lastModified, cacheUntil);

        return http.StreamedResponse(Stream.value(body), 200);
      }
    }
  }

  @override
  void close() {
    _inner.close();
    _cache.close();
  }
}
