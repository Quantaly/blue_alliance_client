import 'cache_provider.dart';

/// An in-memory cache.
class MemoryCache extends TbaCacheProvider {
  final Map<String, _Resource> _cache = {};

  @override
  Future<void> cache(String path, List<int> body, String lastModified,
      DateTime cacheUntil) async {
    print(path);
    _cache[path] = _Resource()
      ..body = body
      ..lastModified = lastModified
      ..cacheUntil = cacheUntil;
  }

  @override
  Future<DateTime> cacheUntil(String path) async => _cache[path].cacheUntil;

  @override
  Future<List<int>> getCached(String path) async => _cache[path].body;

  @override
  Future<bool> isCached(String path) async => _cache.containsKey(path);

  @override
  Future<String> lastModified(String path) async => _cache[path].lastModified;
}

class _Resource {
  List<int> body;
  String lastModified;
  DateTime cacheUntil;
}
