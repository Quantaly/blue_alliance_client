import 'dart:html';
import 'dart:indexed_db';

import 'cache_provider.dart';

const _dbVersion = 1;

/// A cache that stores resources to IndexedDB.
class IndexedDBCache extends TbaCacheProvider {
  final Future<Database> _dbFuture;

  /// Use the given database for the cache.
  IndexedDBCache(String dbName) : _dbFuture = _openDb(dbName);

  static Future<Database> _openDb(String dbName) =>
      window.indexedDB.open(dbName, version: _dbVersion, onUpgradeNeeded: (e) {
        Database db = e.target.result;
        for (var currentVersion = e.oldVersion;
            currentVersion < e.newVersion;
            currentVersion++) {
          switch (currentVersion) {
            case 0:
              db.createObjectStore('cache');
              break;
          }
        }
      });

  @override
  Future<void> cache(String path, List<int> body, String lastModified,
      DateTime cacheUntil) async {
    var db = await _dbFuture;
    var cacheStore = db.transaction('cache', 'readwrite').objectStore('cache');
    await cacheStore.put({
      'body': body,
      'lastModified': lastModified,
      'cacheUntil': cacheUntil.toIso8601String(),
    }, path);
  }

  @override
  Future<DateTime> cacheUntil(String path) async {
    var db = await _dbFuture;
    var cacheStore = db.transaction('cache', 'readonly').objectStore('cache');
    return DateTime.parse((await cacheStore.getObject(path))['cacheUntil']);
  }

  @override
  Future<List<int>> getCached(String path) async {
    var db = await _dbFuture;
    var cacheStore = db.transaction('cache', 'readonly').objectStore('cache');
    return (await cacheStore.getObject(path))['body'];
  }

  @override
  Future<bool> isCached(String path) async {
    var db = await _dbFuture;
    var cacheStore = db.transaction('cache', 'readonly').objectStore('cache');
    return (await cacheStore.count(path)) > 0;
  }

  @override
  Future<String> lastModified(String path) async {
    var db = await _dbFuture;
    var cacheStore = db.transaction('cache', 'readonly').objectStore('cache');
    return (await cacheStore.getObject(path))['lastModified'];
  }

  @override
  void close() async {
    (await _dbFuture).close();
  }
}
