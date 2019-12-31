/// A cache for resources from The Blue Alliance API.
abstract class TbaCacheProvider {
  /// Resolves to whether the resource exists in the cache.
  Future<bool> isCached(String path);

  /// Retrieves the resource from the cache.
  Future<List<int>> getCached(String path);

  /// Returns the value of the `Last-Modified` header on the last retrieval
  /// of this resource.
  Future<String> lastModified(String path);

  /// Returns the time the resource should be cached until, according to the
  /// API.
  Future<DateTime> cacheUntil(String path);

  /// Store the given resource in the cache.
  Future<void> cache(
      String path, List<int> body, String lastModified, DateTime cacheUntil);

  /// Free resources owned by the cache (e.g. file descriptors, IndexedDB
  /// connections).
  void close() {}
}
