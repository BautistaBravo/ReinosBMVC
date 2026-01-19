extends Node2D

class_name Combatant

var data: CharacterData
var is_defending: bool = false
var atb: float = 0.0
const MAX_ATB: float = 100.0

@onready var hp_bar = $HPBar
@onready var atb_bar = $ATBBar
@onready var visual = $Visual

func setup(p_data: CharacterData):
	data = p_data
	hp_bar.max_value = data.max_hp
	hp_bar.value = data.current_hp
	if data.is_enemy:
		visual.color = Color(1, 0, 0) # Red
	else:
		visual.color = Color(0, 0, 1) # Blue

func process_turn(delta):
	if atb < MAX_ATB:
		atb += data.agility * 10.0 * delta
		atb_bar.value = atb
		return false
	return true

func take_damage(amount):
	if is_defending:
		amount /= 2
	data.current_hp -= amount
	hp_bar.value = data.current_hp

	# Flicker effect
	var tween = create_tween()
	tween.tween_property(visual, "modulate:a", 0.0, 0.1)
	tween.tween_property(visual, "modulate:a", 1.0, 0.1)

func attack_target(target: Combatant):
	var tween = create_tween()
	var original_pos = position

	# Move to target
	var dir = (target.position - position).normalized()
	var attack_pos = target.position - dir * 50.0

	tween.tween_property(self, "position", attack_pos, 0.2)
	tween.tween_callback(func(): target.take_damage(data.attack))
	tween.tween_property(self, "position", original_pos, 0.2)

	await tween.finished
	reset_atb()

func reset_atb():
	atb = 0.0
	atb_bar.value = 0.0
	is_defending = false
