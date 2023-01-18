extends Resource
class_name SaveGame

const save_path = "user://savegame.tres"

export var player_data : Resource
export var inventory : Resource
export var world_data : Resource
export var current_room := ""
export var global_position := Vector2.ZERO

func write_savegame() -> void:
	ResourceSaver.save(save_path,self)
	
static func save_exists() -> bool:
	return ResourceLoader.exists(save_path)

static func load_savegame() -> Resource:
	if not ResourceLoader.has_cached(save_path):
		return ResourceLoader.load(save_path,"",true)
	else:
		return null
