extends Control

@onready var label = $Label

func _ready():
	if TimeManager.has_method("register_hud"):
		TimeManager.register_hud(self)

func update_time_label(text: String):
	if label:
		label.text = text
