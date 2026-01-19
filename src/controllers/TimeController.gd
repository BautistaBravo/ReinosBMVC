extends Node

signal day_started
signal night_started

var world_state: WorldState
var time_hud # Reference to TimeHUD

@export var current_time_scale: float = 1.0

func _ready():
	world_state = WorldState.new()
	# Initialize default values if needed, though they are in Resource

func register_hud(hud):
	time_hud = hud

func _process(delta):
	if not world_state: return

	world_state.accumulated_seconds += delta * current_time_scale

	if time_hud and time_hud.has_method("update_time_label"):
		time_hud.update_time_label(get_formatted_time())

	var day_seconds = world_state.day_duration_minutes * 60.0
	var night_seconds = world_state.night_duration_minutes * 60.0
	var cycle_duration = day_seconds + night_seconds

	var current_cycle_time = fmod(world_state.accumulated_seconds, cycle_duration)

	if current_cycle_time < day_seconds:
		if not world_state.is_day:
			world_state.is_day = true
			emit_signal("day_started")
	else:
		if world_state.is_day:
			world_state.is_day = false
			emit_signal("night_started")

func get_game_time_hours() -> float:
	if not world_state: return 0.0

	var day_seconds = world_state.day_duration_minutes * 60.0
	var night_seconds = world_state.night_duration_minutes * 60.0
	var cycle_duration = day_seconds + night_seconds

	var current_cycle_time = fmod(world_state.accumulated_seconds, cycle_duration)

	var game_hour = 0.0

	if current_cycle_time < day_seconds:
		# Day: 06:00 to 18:00 (12 hours) over day_duration
		var ratio = current_cycle_time / day_seconds
		game_hour = 6.0 + (ratio * 12.0)
	else:
		# Night: 18:00 to 06:00 (12 hours) over night_duration
		var ratio = (current_cycle_time - day_seconds) / night_seconds
		game_hour = 18.0 + (ratio * 12.0)
		if game_hour >= 24.0:
			game_hour -= 24.0

	return game_hour

func get_day_number() -> int:
	if not world_state: return 1
	var cycle_duration = (world_state.day_duration_minutes + world_state.night_duration_minutes) * 60.0
	return int(world_state.accumulated_seconds / cycle_duration) + 1

func get_formatted_time() -> String:
	var hours = get_game_time_hours()
	var h = floor(hours)
	var m = floor((hours - h) * 60)
	return "%02d:%02d" % [h, m]

func set_time_scale(scale: float):
	current_time_scale = scale

func get_save_data() -> Dictionary:
	if world_state:
		return world_state.to_dictionary()
	return {}

func load_save_data(data: Dictionary):
	if world_state:
		world_state.from_dictionary(data)
