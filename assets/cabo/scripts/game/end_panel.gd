extends Control

func _on_next_round_pressed():
	get_tree().reload_current_scene()

func declare_winner(player: Player) -> void:
	$PanelContainer/MarginContainer/VBoxContainer/Label.text = str(player) + " WAS CLOSEST TO CABO!"
