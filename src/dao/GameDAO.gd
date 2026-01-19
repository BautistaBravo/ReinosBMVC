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
