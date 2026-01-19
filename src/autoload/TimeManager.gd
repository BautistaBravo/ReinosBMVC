extends Node

signal day_started
signal night_started

@export var day_duration_minutes: float = 8.0
@export var night_duration_minutes: float = 4.0
@export var current_time_scale: float = 1.0

var accumulated_seconds: float = 0.0
var is_day: bool = true

func _process(delta):
	accumulated_seconds += delta * current_time_scale

	var day_seconds = day_duration_minutes * 60.0
	var night_seconds = night_duration_minutes * 60.0
	var cycle_duration = day_seconds + night_seconds

	var current_cycle_time = fmod(accumulated_seconds, cycle_duration)

	if current_cycle_time < day_seconds:
		if not is_day:
			is_day = true
			emit_signal("day_started")
	else:
		if is_day:
			is_day = false
			emit_signal("night_started")

func get_game_time_hours() -> float:
	var day_seconds = day_duration_minutes * 60.0
	var night_seconds = night_duration_minutes * 60.0
	var cycle_duration = day_seconds + night_seconds

	var current_cycle_time = fmod(accumulated_seconds, cycle_duration)

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
	var cycle_duration = (day_duration_minutes + night_duration_minutes) * 60.0
	return int(accumulated_seconds / cycle_duration) + 1

func get_formatted_time() -> String:
	var hours = get_game_time_hours()
	var h = floor(hours)
	var m = floor((hours - h) * 60)
	return "%02d:%02d" % [h, m]

func set_time_scale(scale: float):
	current_time_scale = scale

func get_save_data() -> Dictionary:
	return {
		"accumulated_seconds": accumulated_seconds,
		"is_day": is_day
	}

func load_save_data(data: Dictionary):
	accumulated_seconds = data.get("accumulated_seconds", 0.0)
	is_day = data.get("is_day", true)
