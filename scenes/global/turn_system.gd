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
	turn_index = (turn_index + 1) % player_list.size()
	await get_tree().create_timer(0.5).timeout
	player_list[turn_index].start_turn()

func set_new_card(player, card):
	new_cards[player] = card
	if player.is_player:
		player.has_new_card = true
		for button in player.get_node('Buttons').get_children():
			button.disabled = false
	
func clear_new_card(player):
	new_cards[player] = null
	if player.is_player:
		player.has_new_card = false
		for button in player.get_node('Buttons').get_children():
			button.disabled = true
