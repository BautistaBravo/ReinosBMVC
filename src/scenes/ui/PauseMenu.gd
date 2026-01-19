extends Control

func _on_resume_pressed():
	hide()

func _on_save_pressed():
	GameManager.save_game()

func _on_quit_pressed():
	# For prototype, just go back to main menu
	get_tree().change_scene_to_file(GameManager.MAIN_MENU_SCENE)
