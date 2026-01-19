extends Control

func _on_new_game_pressed():
	GameManager.start_new_game()

func _on_load_game_pressed():
	GameManager.load_game()
