extends Node

var scoreboard: Dictionary

func _ready():
	scoreboard = {}

func get_score(player) -> int:
	return scoreboard[str(player)]

func set_score(score, player) -> void:
	scoreboard[str(player)] = score

func add_score(amount, player) -> void:
	scoreboard[str(player)] += amount

func is_empty() -> bool:
	return scoreboard.is_empty()

func reset() -> void:
	scoreboard.clear()
	
func _process(_delta):
	print(scoreboard)
