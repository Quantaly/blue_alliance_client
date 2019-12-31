import 'dart:io';

import 'package:path/path.dart' as p;

import 'cache_provider.dart';

/// A cache that stores resources to the local file system.
class FileSystemCache extends TbaCacheProvider {
  final String _basePath;

  /// Use the given directory as the root of a cache.
  FileSystemCache(this._basePath);

  String _extendPath(String path) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    return p.normalize(p.join(_basePath, path));
  }

  @override
  Future<void> cache(String path, List<int> body, String lastModified,
      DateTime cacheUntil) async {
    path = _extendPath(path);
    await Future.wait([
      () async {
        var file = File(p.join(path, 'data'));
        await file.create(recursive: true);
        await file.writeAsBytes(body);
      }(),
      () async {
        var file = File(p.join(path, 'mod'));
        await file.create(recursive: true);
        await file.writeAsString(lastModified);
      }(),
      () async {
        var file = File(p.join(path, 'until'));
        await file.create(recursive: true);
        await file.writeAsString(cacheUntil.toIso8601String());
      }(),
    ]);
  }

  @override
  Future<DateTime> cacheUntil(String path) async {
    path = p.join(_extendPath(path), 'until');
    var file = File(path);
    if (!(await file.exists())) {
      return null;
    }
    return DateTime.parse(await file.readAsString());
  }

  @override
  Future<List<int>> getCached(String path) async {
    path = p.join(_extendPath(path), 'data');
    var file = File(path);
    if (!(await file.exists())) {
      return null;
    }
    return file.readAsBytes();
  }

  @override
  Future<bool> isCached(String path) async {
    path = p.join(_extendPath(path), 'data');
    return File(path).exists();
  }

  @override
  Future<String> lastModified(String path) async {
    path = p.join(_extendPath(path), 'mod');
    var file = File(path);
    if (!(await file.exists())) {
      return null;
    }
    return file.readAsString();
  }
}
