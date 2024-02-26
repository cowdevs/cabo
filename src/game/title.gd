extends Node

func _on_play_button_pressed():
	Transition.change_scene("res://src/game/game.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
