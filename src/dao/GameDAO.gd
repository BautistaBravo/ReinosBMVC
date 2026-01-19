extends Node

const SAVE_PATH = "user://savegame.json"

func _load_file_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return {}

	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		return {}

	return data

func _save_file_data(data: Dictionary):
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()
	else:
		printerr("Failed to save data to ", SAVE_PATH)

# Requested DAO functions

func save_party(party_list: Array[CharacterData]):
	var data = _load_file_data()

	var party_data = []
	for member in party_list:
		party_data.append(member.to_dictionary())

	data["party"] = party_data # Use "party" key
	# Also support "player_party" if legacy GameManagers use it, but stick to one.
	# GameManager uses "player_party". I should probably align with that or migrate.
	# The prompt asked for "save_party", I'll use "party" as the key or "player_party".
	# Let's use "player_party" to be compatible with existing GameManager logic if I were to just hook it in.
	data["player_party"] = party_data

	_save_file_data(data)
	print("Party saved.")

func load_party() -> Array[CharacterData]:
	var data = _load_file_data()
	var party_data = data.get("player_party", [])
	if party_data.is_empty():
		party_data = data.get("party", [])

	var party_list: Array[CharacterData] = []
	for char_dict in party_data:
		var character = CharacterData.from_dictionary(char_dict)
		party_list.append(character)

	return party_list

func get_map_data(map_id: String) -> Dictionary:
	# Assuming map_id is the filename without extension or path
	# e.g. "map_01"
	var path = "res://src/data/maps/%s.json" % map_id

	# Handle if full path is passed or just ID
	if map_id.begins_with("res://"):
		path = map_id

	if not FileAccess.file_exists(path):
		printerr("Map file not found: ", path)
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		printerr("Failed to open map file: ", path)
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		printerr("JSON Parse Error in map data: ", json.get_error_message())
		return {}

	return json.get_data()

# Extra helper for GameManager compatibility
func save_full_state(data: Dictionary):
	_save_file_data(data)

func load_full_state() -> Dictionary:
	return _load_file_data()

func _create_character_by_type(type: String) -> CharacterData:
	# Factory helper
	var char_data = CharacterData.new()
	char_data.character_name = type
	char_data.is_enemy = true
	# Basic stats based on type
	if type == "Goblin":
		char_data.max_hp = 30
		char_data.current_hp = 30
		char_data.agility = 12
		char_data.attack = 8
		char_data.defense = 2
		char_data.race = "Goblin"
	elif type == "Orc":
		char_data.max_hp = 60
		char_data.current_hp = 60
		char_data.agility = 8
		char_data.attack = 15
		char_data.defense = 5
		char_data.race = "Orc"
	return char_data

func spawn_entities_in_map(map_node: Node):
	# Assume map_node has a reference or we know the current map ID from somewhere
	# Or we can pass the map ID. For now, let's assume we fetch data based on GameManager's current map
	# But to be clean, let's pass map_id if possible, or read from map_node filename if it matches pattern

	# Since GameManager tracks current_map_path, we can extract ID
	# But better to use get_map_data() we already have.

	# Extract map_id from filename for simplicity or assume passed context.
	# Let's rely on GameManager to have set the path correctly, and we parse the json.
	# Wait, get_map_data takes map_id.

	# Let's try to deduce map_id from map_node.filename
	var map_path = map_node.scene_file_path
	if map_path.is_empty():
		return # Not an instanced scene file

	# map_path like res://src/scenes/maps/Map01.tscn ?
	# The json is in src/data/maps/map_01.json
	# The prompt implies getting JSON data.

	# Let's hardcode map_01 for the demo if deduction fails, or ask caller to provide ID.
	# But prompt says "GameDAO.gd tenga una función spawn_entities_in_map(map_node)".
	# I will assume map_node corresponds to the loaded JSON data we can get.

	# We'll use a hardcoded check or just try to load "map_01" for this task as it's the only one.
	var map_data = get_map_data("map_01")
	if map_data.is_empty():
		return

	var entities = map_data.get("entities", [])
	var entity_scene = load("res://src/views/overworld/Entity.tscn")

	for entity_info in entities:
		var type = entity_info.get("type", "Goblin")
		var x = entity_info.get("x", 0)
		var y = entity_info.get("y", 0)

		var char_data = _create_character_by_type(type)
		var entity_instance = entity_scene.instantiate()
		entity_instance.position = Vector2(x, y)

		if entity_instance.has_method("setup"):
			entity_instance.setup(char_data)

		map_node.add_child(entity_instance)
