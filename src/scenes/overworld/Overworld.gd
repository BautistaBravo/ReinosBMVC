extends Node2D

@onready var terrain_container = $TerrainContainer
@onready var entity_container = $EntityContainer

func _ready():
	if GameManager.current_map_path != "":
		load_map_data(GameManager.current_map_path)
	else:
		# Fallback or load default for testing
		load_map_data("res://src/data/maps/map_01.json")

func load_map_data(file_path: String):
	if not FileAccess.file_exists(file_path):
		printerr("Map file not found: " + file_path)
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)

	if error == OK:
		var data = json.data
		build_level(data)
	else:
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())

func build_level(data: Dictionary):
	# Clear existing
	for child in terrain_container.get_children():
		child.queue_free()
	for child in entity_container.get_children():
		child.queue_free()

	# Load Terrain
	if data.has("terrain_path"):
		var terrain_scene = load(data["terrain_path"])
		if terrain_scene:
			var terrain = terrain_scene.instantiate()
			terrain_container.add_child(terrain)

	# Load Entities
	if data.has("entities"):
		for entity_data in data["entities"]:
			spawn_entity(entity_data)

func spawn_entity(data: Dictionary):
	var type = data.get("type", "")
	var x = data.get("x", 0)
	var y = data.get("y", 0)

	if type == "":
		return

	# Resolve path - Assumption: scenes are in src/scenes/entities/
	var path = "res://src/scenes/entities/%s.tscn" % type

	if ResourceLoader.exists(path):
		var scene = load(path)
		if scene:
			var entity = scene.instantiate()
			entity.position = Vector2(x, y)
			entity_container.add_child(entity)
	else:
		printerr("Entity scene not found: " + path)
