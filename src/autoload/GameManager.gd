extends Node

var player_party: Array = [] # Array[CharacterData]
var current_enemy_party: Array = [] # Array[CharacterData]
var current_map_path: String = "res://src/data/maps/map_01.json"

const MAIN_MENU_SCENE = "res://src/scenes/main_menu/MainMenu.tscn"
const OVERWORLD_SCENE = "res://src/scenes/overworld/Overworld.tscn"
const COMBAT_SCENE = "res://src/scenes/combat/Combat.tscn"

func _ready():
	pass

func start_new_game():
	player_party.clear()
	# Create default party
	var hero = CharacterData.new("Hero", 120, 15, 20, 10, false, "Human")
	var ally = CharacterData.new("Mage", 90, 12, 25, 5, false, "Elf")
	player_party.append(hero)
	player_party.append(ally)

	TimeManager.set_time_scale(1.0)
	get_tree().change_scene_to_file(OVERWORLD_SCENE)

func start_combat(enemy_party: Array):
	current_enemy_party = enemy_party
	TimeManager.set_time_scale(0.5)
	get_tree().change_scene_to_file(COMBAT_SCENE)

func return_to_overworld():
	current_enemy_party.clear()
	TimeManager.set_time_scale(1.0)
	get_tree().change_scene_to_file(OVERWORLD_SCENE)

func save_game():
	var save_data = {
		"current_map_path": current_map_path,
		"time_data": TimeManager.get_save_data(),
		"player_party": []
	}

	for member in player_party:
		save_data["player_party"].append(member.to_dictionary())

	GameDAO.save_full_state(save_data)
	print("Game saved.")

func load_game():
	var data = GameDAO.load_full_state()
	if data.is_empty():
		print("No save file found or empty. Starting new game.")
		start_new_game()
		return

	apply_save_data(data)

func apply_save_data(data: Dictionary):
	current_map_path = data.get("current_map_path", "res://src/data/maps/map_01.json")

	if data.has("time_data"):
		TimeManager.load_save_data(data["time_data"])

	player_party.clear()
	if data.has("player_party"):
		for member_data in data["player_party"]:
			player_party.append(CharacterData.from_dictionary(member_data))

	TimeManager.set_time_scale(1.0)
	get_tree().change_scene_to_file(OVERWORLD_SCENE)
