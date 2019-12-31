import 'package:archive/archive.dart';

import 'cache_provider.dart';

/// Stores the response body in a compressed format via an inner cache.
class TbaCacheCompressor extends TbaCacheProvider {
  final TbaCacheProvider _inner;

  /// Provide an inner cache provider to store resources.
  TbaCacheCompressor(this._inner);

  @override
  Future<void> cache(
      String path, List<int> body, String lastModified, DateTime cacheUntil) {
    return _inner.cache(
        path, GZipEncoder().encode(body), lastModified, cacheUntil);
  }

  @override
  Future<DateTime> cacheUntil(String path) {
    return _inner.cacheUntil(path);
  }

  @override
  Future<List<int>> getCached(String path) async {
    return GZipDecoder().decodeBytes(await _inner.getCached(path));
  }

  @override
  Future<bool> isCached(String path) {
    return _inner.isCached(path);
  }

  @override
  Future<String> lastModified(String path) {
    return _inner.lastModified(path);
  }

  @override
  void close() {
    _inner.close();
  }
}
