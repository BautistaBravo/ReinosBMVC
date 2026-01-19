extends Node2D

@onready var allies_pos = $AlliesPos
@onready var enemies_pos = $EnemiesPos
@onready var combat_ui = $CombatUI

var combat_controller: CombatController

func _ready():
	# Instantiate Controller
	combat_controller = CombatController.new()
	add_child(combat_controller)

	# Connect Controller Logic
	# 1. Get Party Data (Usually from GameManager)
	var player_party = GameManager.player_party
	var enemy_party = GameManager.current_enemy_party

	# 2. Setup Visuals (Spawn sprites at positions)
	_spawn_combatants(player_party, allies_pos)
	_spawn_combatants(enemy_party, enemies_pos)

	# 3. Give Control to Controller
	combat_controller.initialize(player_party, enemy_party, combat_ui)

	# 4. Connect Signal for End of Combat
	combat_controller.combat_ended.connect(_on_combat_ended)

func _spawn_combatants(party: Array, parent_node: Node):
	var index = 0
	for member in party:
		# In a real game, instantiate a sprite/scene based on member data
		# using a marker or just offsetting by index
		var sprite = Sprite2D.new()
		sprite.texture = load("res://icon.svg") # Placeholder
		sprite.position = Vector2(0, index * 100) # Vertical stacking
		if member.is_enemy:
			sprite.modulate = Color(1, 0.5, 0.5) # Reddish for enemies
			sprite.position.x = 0 # Relative to EnemiesPos
		else:
			sprite.position.x = 0 # Relative to AlliesPos

		parent_node.add_child(sprite)
		index += 1

func _on_combat_ended(victory: bool):
	print("Combat Stage: Ended. Victory? ", victory)
	if victory:
		GameManager.return_to_overworld()
	else:
		# Handle game over
		print("Game Over")
		GameManager.return_to_overworld() # Or main menu
