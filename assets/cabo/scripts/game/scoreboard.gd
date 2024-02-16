extends Node2D

var scoreboard := {}

func get_scoreboard() -> Dictionary:
	return scoreboard

func get_score(player) -> int:
	return scoreboard[player]

func set_score(score, player) -> void:
	scoreboard[player] = score

func add_score(amount, player) -> void:
	scoreboard[player] += amount	

func is_empty() -> bool:
	return scoreboard.is_empty()

func reset() -> void:
	scoreboard.clear()
