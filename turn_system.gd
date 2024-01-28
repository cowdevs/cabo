extends Node

var player_list = []
var new_cards = {}
var current_turn = 0

func add_player(player):
	player_list.append(player)

func start_game():
	if player_list.size() > 0:
		player_list[current_turn].start_turn()

func end_turn():
	player_list[current_turn].end_turn()
	current_turn = (current_turn + 1) % player_list.size()
	player_list[current_turn].start_turn()
