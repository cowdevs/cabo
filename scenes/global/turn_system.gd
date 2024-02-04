extends Node

var player_list
var new_cards
var turn_index: int
var final_round: bool

func _ready():
	player_list = []
	new_cards = {}
	turn_index = 0
	final_round = false

func add_player(player):
	player_list.append(player)

func remove_player(player):
	player_list.erase(player)

func end_turn():
	if final_round:
		remove_player(player_list[turn_index])
	if player_list.size() == 0:
		end_game()
	else:
		turn_index = (turn_index + 1) % player_list.size()
		await get_tree().create_timer(0.5).timeout
		player_list[turn_index].start_turn()

func start_game():
	get_node("/root/GameScreen/ActionButtons/CaboButton").connect('pressed', _on_cabo_button_pressed)
	if player_list.size() > 0:
		player_list[turn_index].start_turn()

func end_game():
	for player in get_node("/root/GameScreen/Players").get_children():
		for card in player.get_node('Hand').get_children():
			card.flip()
	print(get_winner())
	await get_tree().create_timer(5).timeout
	get_tree().reload_current_scene() 

func get_winner():
	var min_sum = 50
	var winner = null
	for player in get_node("/root/GameScreen/Players").get_children():
		var player_sum = CardSystem.get_sum(player.hand)
		if player_sum < min_sum:
			min_sum = player_sum
			winner = player
	return winner

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

func _on_cabo_button_pressed():
	get_node("/root/GameScreen/ActionButtons/CaboButton").disabled = true
	final_round = true
	end_turn()
