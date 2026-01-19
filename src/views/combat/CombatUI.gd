extends Control

# Placeholder for UI elements
# In a real scene, these would be linked via @onready
# e.g. @onready var hp_bar = $HPBar

signal player_selected_action(target_index)

func _ready():
	print("Combat UI Initialized")

func set_hp_bar(character: CharacterData, value: int):
	# Example: $HPBar.value = value
	print("UI: Set HP for %s to %d" % [character.character_name, value])

func update_hp_bar(character: CharacterData):
	print("UI: Updated HP bar for %s: %d/%d" % [character.character_name, character.current_hp, character.max_hp])

func update_atb_bars(combatants: Array):
	# combatants is list of dicts with "data" and "atb"
	# In real UI, iterate and update progress bars
	pass

func play_attack_animation(attacker: CharacterData, target: CharacterData):
	print("UI: Playing attack animation: %s -> %s" % [attacker.character_name, target.character_name])
	# Here we would play animationPlayer or tween

func show_damage_number(target: CharacterData, amount: int):
	print("UI: Floating text %d on %s" % [amount, target.character_name])

func enable_player_input(character: CharacterData):
	print("UI: Waiting for input for %s" % character.character_name)
	# Unlock buttons
	# For testing, we might auto-select or just wait
	# emit_signal("player_selected_action", 0) # Auto attack first enemy

func _on_AttackButton_pressed():
	# Example button callback
	emit_signal("player_selected_action", 0) # Target index 0
