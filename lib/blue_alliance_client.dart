/// A wrapper for making API calls to The Blue Alliance through an
/// [http.Client].
/// 
/// [TbaClient] provides authentication and caching, with a built-in
/// [MemoryCache] implementation. Persistent caches for the browser and
/// VM/Flutter are provided in separate libraries.
/// 
/// You can create your own cache by implementing [TbaCacheProvider].
library blue_alliance_client;

import 'package:http/http.dart' as http;

import 'blue_alliance_client.dart';

export 'src/caching/cache_provider.dart';
export 'src/caching/compression.dart';
export 'src/caching/memory_cache.dart';
export 'src/client.dart';
