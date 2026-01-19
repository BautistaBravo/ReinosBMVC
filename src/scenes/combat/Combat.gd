extends Node2D

@export var combatant_scene: PackedScene
var combatants: Array = []
var ready_combatants: Array = []
var active_combatant_index: int = -1

@onready var ui_layer = $UI
@onready var command_label = $UI/CommandLabel

func _ready():
	# Spawn characters
	spawn_party(GameManager.player_party, Vector2(800, 200), true)
	spawn_party(GameManager.current_enemy_party, Vector2(200, 200), false)
	ui_layer.visible = false

func spawn_party(party, start_pos, is_player):
	for i in range(party.size()):
		var c = combatant_scene.instantiate()
		add_child(c)
		c.position = start_pos + Vector2(0, i * 100)
		c.setup(party[i])
		combatants.append(c)

func _process(delta):
	if active_combatant_index != -1:
		return # Waiting for input or action

	var anyone_ready = false

	# Charge ATB
	for c in combatants:
		if c.data.current_hp > 0 and not c in ready_combatants:
			if c.process_turn(delta):
				ready_combatants.append(c)

	if ready_combatants.size() > 0:
		start_turn_phase()

func start_turn_phase():
	if active_combatant_index == -1:
		active_combatant_index = 0

	update_active_combatant()

func update_active_combatant():
	if ready_combatants.is_empty():
		active_combatant_index = -1
		ui_layer.visible = false
		return

	# Wrap index
	if active_combatant_index >= ready_combatants.size():
		active_combatant_index = 0
	if active_combatant_index < 0:
		active_combatant_index = ready_combatants.size() - 1

	var c = ready_combatants[active_combatant_index]

	if c.data.is_enemy:
		# Enemy acts immediately
		perform_enemy_turn(c)
	else:
		# Player input
		ui_layer.visible = true
		command_label.text = "Player: %s\nARROWS: Select\nA: Attack\nD: Defend\nH: Flee" % c.data.character_name

		# Position UI over character
		command_label.position = c.position + Vector2(-50, -150)

func _input(event):
	if not ui_layer.visible:
		return

	if active_combatant_index != -1 and not ready_combatants.is_empty():
		var c = ready_combatants[active_combatant_index]
		if not c.data.is_enemy:
			if event.is_action_pressed("ui_up"):
				active_combatant_index -= 1
				update_active_combatant()
			elif event.is_action_pressed("ui_down"):
				active_combatant_index += 1
				update_active_combatant()

			if event is InputEventKey and event.pressed:
				if event.keycode == KEY_A:
					perform_attack(c)
				elif event.keycode == KEY_D:
					perform_defend(c)
				elif event.keycode == KEY_H:
					perform_flee(c)

func perform_enemy_turn(enemy):
	ui_layer.visible = false
	# Find target (random player)
	var targets = combatants.filter(func(x): return !x.data.is_enemy and x.data.current_hp > 0)
	if targets.size() > 0:
		var target = targets.pick_random()
		await enemy.attack_target(target)
	else:
		enemy.reset_atb()

	finish_action(enemy)

func perform_attack(attacker):
	ui_layer.visible = false
	# Nearest enemy
	var enemies = combatants.filter(func(x): return x.data.is_enemy and x.data.current_hp > 0)
	var nearest = null
	var min_dist = INF
	for e in enemies:
		var d = attacker.position.distance_to(e.position)
		if d < min_dist:
			min_dist = d
			nearest = e

	if nearest:
		await attacker.attack_target(nearest)
	else:
		attacker.reset_atb()

	finish_action(attacker)

func perform_defend(attacker):
	ui_layer.visible = false
	attacker.is_defending = true
	attacker.reset_atb()
	finish_action(attacker)

func perform_flee(attacker):
	ui_layer.visible = false
	if randf() < 0.5:
		GameManager.return_to_overworld()
	else:
		attacker.reset_atb()
		finish_action(attacker)

func finish_action(c):
	ready_combatants.erase(c)
	active_combatant_index = -1
	check_battle_end()

func check_battle_end():
	var enemies_alive = combatants.filter(func(x): return x.data.is_enemy and x.data.current_hp > 0).size()
	var players_alive = combatants.filter(func(x): return !x.data.is_enemy and x.data.current_hp > 0).size()

	if enemies_alive == 0:
		print("Victory!")
		GameManager.return_to_overworld()
	elif players_alive == 0:
		print("Defeat!")
		GameManager.return_to_overworld() # Or game over screen
