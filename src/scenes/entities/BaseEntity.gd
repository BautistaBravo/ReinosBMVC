extends Area2D

@export var entity_name: String = "Goblin"
@export var is_enemy: bool = true
@export var loot_table: Resource
var party: Array = []

func _ready():
	# Enable mouse detection
	input_pickable = true

	# Connect signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# Create a mock party for the entity
	if party.is_empty():
		# Determine race based on entity name map or default
		var race = "Goblin" if "Goblin" in entity_name else "Orc"
		var leader = CharacterData.new(entity_name, 50, 8, 15, 2, true, race)
		party.append(leader)
		if is_enemy:
			# Maybe add a minion
			party.append(CharacterData.new("Minion", 30, 6, 10, 1, true, "Goblin"))

func _on_mouse_entered():
	get_tree().call_group("overworld_ui", "show_tooltip", self)

func _on_mouse_exited():
	get_tree().call_group("overworld_ui", "hide_tooltip")

func interact():
	if is_enemy:
		print("Starting combat with " + entity_name)
		GameManager.start_combat(party, loot_table)
	else:
		print("Hello traveler!")
