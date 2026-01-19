extends Resource
class_name WorldState

@export var accumulated_seconds: float = 0.0
@export var is_day: bool = true
@export var day_duration_minutes: float = 8.0
@export var night_duration_minutes: float = 4.0

# Store transient or persistent entities for the current map
# List of Dictionaries or CharacterData, depending on persistence needs
@export var current_map_entities: Array = []

func to_dictionary() -> Dictionary:
	return {
		"accumulated_seconds": accumulated_seconds,
		"is_day": is_day
	}

func from_dictionary(data: Dictionary):
	accumulated_seconds = data.get("accumulated_seconds", 0.0)
	is_day = data.get("is_day", true)
