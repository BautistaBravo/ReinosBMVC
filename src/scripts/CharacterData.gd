extends Resource
class_name CharacterData

@export var character_name: String = "Unnamed"
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var agility: int = 10
@export var attack: int = 10
@export var defense: int = 5
@export var is_enemy: bool = false

@export var level: int = 1
@export var current_xp: int = 0
@export var race: String = "Human"

signal leveled_up(new_level)

const RACE_XP_MULTIPLIERS = {
	"Human": 1.0,
	"Elf": 1.5,
	"Orc": 1.2,
	"Goblin": 0.8
}

# Simple constructor-like init if needed, but Resources are usually just new()
func _init(p_name = "Unnamed", p_hp = 100, p_agi = 10, p_atk = 10, p_def = 5, p_is_enemy = false, p_race = "Human", p_level = 1, p_xp = 0):
	character_name = p_name
	max_hp = p_hp
	current_hp = p_hp
	agility = p_agi
	attack = p_atk
	defense = p_def
	is_enemy = p_is_enemy
	race = p_race
	level = p_level
	current_xp = p_xp

func add_experience(amount: int):
	current_xp += amount
	print("%s gained %d XP. Total: %d" % [character_name, amount, current_xp])

	var xp_needed = get_xp_for_next_level()
	while current_xp >= xp_needed:
		current_xp -= xp_needed
		_level_up()
		xp_needed = get_xp_for_next_level()

func get_xp_for_next_level() -> int:
	var multiplier = RACE_XP_MULTIPLIERS.get(race, 1.0)
	var base_xp = 100
	return int(base_xp * level * multiplier)

func _level_up():
	level += 1
	# Increase stats by 10%
	max_hp = int(max_hp * 1.1)
	current_hp = max_hp # Heal on level up
	attack = int(attack * 1.1)
	defense = int(defense * 1.1)
	# Agility might need careful tuning, but let's do 5% or +1
	agility = int(agility * 1.05) + 1

	emit_signal("leveled_up", level)
	print("%s leveled up to %d!" % [character_name, level])

func to_dictionary() -> Dictionary:
	return {
		"character_name": character_name,
		"max_hp": max_hp,
		"current_hp": current_hp,
		"agility": agility,
		"attack": attack,
		"defense": defense,
		"is_enemy": is_enemy,
		"race": race,
		"level": level,
		"current_xp": current_xp
	}

static func from_dictionary(data: Dictionary) -> CharacterData:
	var char_data = CharacterData.new(
		data.get("character_name", "Unnamed"),
		data.get("max_hp", 100),
		data.get("agility", 10),
		data.get("attack", 10),
		data.get("defense", 5),
		data.get("is_enemy", false),
		data.get("race", "Human"),
		data.get("level", 1),
		data.get("current_xp", 0)
	)
	char_data.current_hp = data.get("current_hp", char_data.max_hp)
	return char_data
