extends CharacterBody2D

const SPEED = 200.0

@onready var interaction_area = $InteractionArea

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()

	if Input.is_action_just_pressed("ui_accept"):
		try_interact()

func try_interact():
	if interaction_area:
		var areas = interaction_area.get_overlapping_areas()
		for area in areas:
			if area.has_method("interact"):
				area.interact()
				return
