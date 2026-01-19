extends Node
class_name CombatController

signal combat_log(message: String)
signal turn_started(character: CharacterData)
signal combat_ended(victory: bool)

var allies: Array[CharacterData] = []
var enemies: Array[CharacterData] = []
var all_combatants: Array = [] # Stores { "data": CharacterData, "atb": float }

var combat_ui # Reference to CombatUI (Vista)
var active_combatant_data: CharacterData = null
var is_combat_active: bool = false
const ATB_THRESHOLD: float = 100.0

func initialize(p_allies: Array[CharacterData], p_enemies: Array[CharacterData], p_ui):
	allies = p_allies
	enemies = p_enemies
	combat_ui = p_ui

	if combat_ui.has_signal("player_selected_action"):
		combat_ui.player_selected_action.connect(on_player_attack)

	all_combatants.clear()

	for ally in allies:
		all_combatants.append({ "data": ally, "atb": 0.0, "is_enemy": false })
	for enemy in enemies:
		all_combatants.append({ "data": enemy, "atb": 0.0, "is_enemy": true })

	is_combat_active = true
	emit_signal("combat_log", "Combat Started!")
	_update_ui_bars()

func _process(delta):
	if not is_combat_active:
		return

	if active_combatant_data != null:
		return # Waiting for player input or animation

	# ATB accumulation
	for combatant in all_combatants:
		if combatant.data.current_hp <= 0:
			continue

		var speed = combatant.data.agility # Simplified speed
		combatant.atb += speed * delta * 5.0 # multiplier to speed up

		if combatant.atb >= ATB_THRESHOLD:
			combatant.atb = ATB_THRESHOLD
			_start_turn(combatant.data)
			break # Only one turn start per frame to avoid conflicts

	_update_ui_bars()

func _start_turn(character: CharacterData):
	active_combatant_data = character
	emit_signal("turn_started", character)
	emit_signal("combat_log", "%s's turn!" % character.character_name)

	if character.is_enemy:
		# Simple AI: attack random ally
		var target = _get_random_living_ally()
		if target:
			execute_attack(character, target)
		else:
			_end_turn() # Should imply game over but let's be safe
	else:
		# Player turn: notify UI to enable inputs
		if combat_ui.has_method("enable_player_input"):
			combat_ui.enable_player_input(character)

func execute_attack(attacker: CharacterData, target: CharacterData):
	if not is_combat_active: return

	var damage = attacker.calculate_damage_to(target)
	target.current_hp = max(0, target.current_hp - damage)

	emit_signal("combat_log", "%s attacks %s for %d damage!" % [attacker.character_name, target.character_name, damage])

	# Update View
	if combat_ui.has_method("play_attack_animation"):
		combat_ui.play_attack_animation(attacker, target)
	if combat_ui.has_method("show_damage_number"):
		combat_ui.show_damage_number(target, damage)
	if combat_ui.has_method("update_hp_bar"):
		combat_ui.update_hp_bar(target)

	if target.current_hp <= 0:
		emit_signal("combat_log", "%s has been defeated!" % target.character_name)
		_check_combat_end()

	# Wait a bit or let animation finish trigger next turn
	# For simplicity, we just end turn here, but in real usage might wait for signal
	_end_turn()

func _end_turn():
	if active_combatant_data:
		# Reset ATB for the one who acted
		for combatant in all_combatants:
			if combatant.data == active_combatant_data:
				combatant.atb = 0.0
				break

	active_combatant_data = null
	_check_combat_end()

func _check_combat_end():
	var allies_alive = 0
	for ally in allies:
		if ally.current_hp > 0: allies_alive += 1

	var enemies_alive = 0
	for enemy in enemies:
		if enemy.current_hp > 0: enemies_alive += 1

	if allies_alive == 0:
		is_combat_active = false
		emit_signal("combat_ended", false)
		emit_signal("combat_log", "Defeat...")
	elif enemies_alive == 0:
		is_combat_active = false
		emit_signal("combat_ended", true)
		emit_signal("combat_log", "Victory!")

func _get_random_living_ally() -> CharacterData:
	var living = []
	for ally in allies:
		if ally.current_hp > 0: living.append(ally)
	if living.is_empty(): return null
	return living.pick_random()

func _update_ui_bars():
	if combat_ui.has_method("update_atb_bars"):
		combat_ui.update_atb_bars(all_combatants)

# Public function called by View when player selects a command
func on_player_attack(target_index: int):
	if active_combatant_data == null or active_combatant_data.is_enemy:
		return

	var target = enemies[target_index]
	if target.current_hp > 0:
		execute_attack(active_combatant_data, target)
