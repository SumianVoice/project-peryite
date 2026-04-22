
# Chunk Versioning
By default, this will store which numerical version (protocol, game build version etc) for every newly generated chunk. Then, you can freely query any chunk's version.

## Functions you should care about
```lua
-- Set this from any mod, usually your game's "meta" mod. This is the number that is saved in the chunk.
GAMEVERSION = 0
-- This is what you would use to get which version this chunk was generated in. This does `tonumber(x, 16)` so don't use unnecessarily.
ChunkVersion.get_generated_version(pos, default) --> number or default
-- Default is false and the above will save `0` and the below will return that too as a default.
ChunkVersion.store_timestamp = false
-- Unix epoch as a number, same format as `os.time()`. If the above was false when this chunk generated, returns 0.
ChunkVersion.get_generated_timestamp(pos, default) --> number or default
-- Avoid using this; allows you to overwrite the generated version. Only useful if you completely delete and manually replace the entire chunk. [Re]generating a new chunk will already do this.
ChunkVersion.set_generated_version(pos, version_number)
```

### Why is the timestamp not saved by default?
It would take about 4x the storage as the version on average and most people don't need it. As such, if you think you will need it in your game, just set it as true on server startup.
