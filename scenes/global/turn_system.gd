extends Node

var player_list = []
var new_cards = {}
var turn_index = 0

func add_player(player):
	player_list.append(player)

func start_game():
	if player_list.size() > 0:
		player_list[turn_index].start_turn()

func end_turn():
	player_list[turn_index].end_turn()
	turn_index = (turn_index + 1) % player_list.size()
	player_list[turn_index].start_turn()
	print(str(player_list[turn_index]) + '\'s turn')

