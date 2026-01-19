extends Node2D

var character_data: CharacterData

func setup(data: CharacterData):
	character_data = data
	# In a real game, we'd load a sprite based on race/type
	# For now, we can just change the name or color if we had a sprite
	# $Sprite2D.texture = load("res://assets/sprites/%s.png" % data.race)
	name = data.character_name
	print("Entity spawned: %s at %s" % [name, position])
