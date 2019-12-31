# blue_alliance_client

A simple library to handle caching and authentication for API requests to [The Blue Alliance](https://www.thebluealliance.com/), a popular database for the [_FIRST_ Robotics Competition](https://www.firstinspires.org/robotics/frc).

Three cache implementations are provided - a `MemoryCache`, a `FileSystemCache`, and an `IndexedDBCache` - as well as a `TbaCacheCompressor` that can sit between the client and the cache.

See also [The Blue Alliance's API documentation](https://www.thebluealliance.com/apidocs).