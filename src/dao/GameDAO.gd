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
	# Data-driven factory
	var path = "res://src/data/characters/%s.json" % type

	if not FileAccess.file_exists(path):
		printerr("Character type definition not found: ", path)
		# Return a default fallback to prevent crashes, or null
		var fallback = CharacterData.new()
		fallback.character_name = type
		return fallback

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		printerr("Failed to open character file: ", path)
		return CharacterData.new()

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		printerr("JSON Parse Error for character ", type, ": ", json.get_error_message())
		return CharacterData.new()

	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		printerr("Character data is not a dictionary: ", path)
		return CharacterData.new()

	# Create CharacterData from dictionary
	# Note: CharacterData.from_dictionary is a static method we implemented
	var char_data = CharacterData.from_dictionary(data)
	return char_data

func spawn_entities_in_map(map_node: Node):
	# Use GameManager's current map path to fetch data
	var map_path = GameManager.current_map_path

	if not FileAccess.file_exists(map_path):
		printerr("Map data file not found: ", map_path)
		return

	# Reuse get_map_data if possible, but it expects an ID.
	# We can just load the file directly since we have the full path.
	var file = FileAccess.open(map_path, FileAccess.READ)
	if not file:
		printerr("Failed to open map data: ", map_path)
		return

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		printerr("JSON Parse Error in map data: ", json.get_error_message())
		return

	var map_data = json.get_data()
	if typeof(map_data) != TYPE_DICTIONARY:
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
