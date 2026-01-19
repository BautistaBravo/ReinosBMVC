extends Resource
class_name LootTable

@export var items: Array[Resource] = []
@export var probabilities: Array[float] = []

func roll_loot() -> Array:
	var drops = []
	for i in range(items.size()):
		if i < probabilities.size():
			if randf() <= probabilities[i]:
				drops.append(items[i])
	return drops
