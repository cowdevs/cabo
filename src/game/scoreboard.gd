extends Node2D

var scoreboard := {}

func get_scoreboard() -> Dictionary:
	return scoreboard

func get_score(player) -> int:
	return scoreboard[player]

func set_score(score, player) -> void:
	scoreboard[player] = score

func add_score(amount, player) -> int:
	scoreboard[player] += amount
	return amount

func get_winning_players() -> Array:
	var winning_players := []
	var min_score = INF
	for player in scoreboard:
		min_score = min(min_score, get_score(player))
	for player in scoreboard:
		if get_score(player) == min_score:
			winning_players.append(player)
	return winning_players

func is_empty() -> bool:
	return scoreboard.is_empty()

func reset() -> void:
	scoreboard.clear()
