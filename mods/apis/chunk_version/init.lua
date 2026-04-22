---@diagnostic disable: undefined-doc-name

---Stores information about when chunks were generated.
ChunkVersion = {}
---If true, stores the unix epoch timestamp. Approx 8 bytes per chunk, 512mb per fully explored world.
ChunkVersion.store_timestamp = false
ChunkVersion.mod_storage = core.get_mod_storage()
---Set by game core mod.
GAMEVERSION = rawget(_G, "GAMEVERSION") or 0

local chunk_width = core.get_mapgen_setting("chunksize") * core.MAP_BLOCKSIZE
local chunk_offset = vector.new(3,3,3) * core.MAP_BLOCKSIZE

local function pos_to_chunk_index(pos, is_ceil)
	local cpos = (pos - chunk_offset) / (chunk_width)
	if is_ceil then
		return vector.ceil(cpos)
	else
		return vector.floor(cpos)
	end
end

local function pos_to_storage_key(pos, prefix)
	return (prefix or "") .. vector.to_string(pos_to_chunk_index(pos, nil))
end

-- respect `backend == dummy`
local force_no_persistence = false
do
	local world_path = core.get_worldpath()
	local world_mt = Settings(world_path .. "/world.mt")
	force_no_persistence = (world_mt:get("backend") == "dummy")
	if force_no_persistence then
		for k, v in pairs(ChunkVersion.mod_storage:get_keys()) do
			if string.sub(k, 1, 1) == "(" then
				ChunkVersion.mod_storage:set_string(k, "")
			end
		end
	end
end

---Sets the version a chunk is listed as being generated at.
---@param pos vector
---@param v number
function ChunkVersion.set_generated_version(pos, v)
	local key = pos_to_storage_key(pos, "g")
	ChunkVersion.mod_storage:set_string(key, string.format("%X", v))
	-- optionally save timestamp
	if ChunkVersion.store_timestamp then
		key = pos_to_storage_key(pos, "t")
		ChunkVersion.mod_storage:set_string(key, string.format("%X", os.time()))
	end
end

---Gets the version this chunk was generated at.
---@param pos vector
---@param default number|nil
---@return number
function ChunkVersion.get_generated_version(pos, default)
	local key = pos_to_storage_key(pos, "g")
	local value = ChunkVersion.mod_storage:get_string(key)
	if value == "" then return default or 0 end
	local version = tonumber(value, 16)
	return version or default or 0
end

---Gets the timestamp in unix epoch the chunk was generated. If not enabled, returns default or 0.
---@param pos vector
---@param default number|nil
---@return number
function ChunkVersion.get_generated_timestamp(pos, default)
	local key = pos_to_storage_key(pos, "t")
	local value = ChunkVersion.mod_storage:get_string(key)
	if value == "" then return default or 0 end
	local timestamp = tonumber(value, 16)
	return timestamp or default or 0
end

core.register_on_generated(function(minp, maxp, blockseed)
	ChunkVersion.set_generated_version(minp, GAMEVERSION)
end)
