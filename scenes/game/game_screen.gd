extends Node2D

var Player = preload("res://scenes/game/player/player/player.tscn")
var Computer = preload("res://scenes/game/player/computer/computer.tscn")

var num_computers = 1

func _ready():
	player_list = []
	new_cards = {}
	turn_index = 0
	final_round = false
	
	$Players.add_child(Player.instantiate())
	for i in range(num_computers):
		$Players.add_child(Computer.instantiate())
	
	$Players.get_child(0).is_main_player = true
	
	for i in range($Players.get_child_count()):
		new_cards[$Players.get_child(i)] = null
	
	set_player_positions()
		
	for player in $Players.get_children():
		add_player(player)

	CardSystem.deck.shuffle()
	
	for player in $Players.get_children():
		$Deck.first_hand(player)
	
	var first_card = CardSystem.pop_card(CardSystem.deck) 
	first_card.discard()

	CardSystem.update(CardSystem.deck)
	CardSystem.update(CardSystem.pile)
	
	$ActionButtons.hide_buttons()
	
	start_game()

func set_player_positions():
	var positions = [Vector2(800, 1050), Vector2(800, 150)] if $Players.get_child_count() == 2 else [Vector2(800, 1050), Vector2(150, 600), Vector2(800, 150), Vector2(1450, 600)]
	var rotations = [0, PI] if $Players.get_child_count() == 2 else [0, PI / 2, PI, -(PI / 2)]
	for i in $Players.get_child_count():
		$Players.get_child(i).position = positions[i]
		$Players.get_child(i).rotation = rotations[i]

var player_list
var new_cards
var turn_index: int
var final_round: bool

func add_player(player):
	player_list.append(player)

func remove_player(player):
	player_list.erase(player)

func end_turn():
	if final_round:
		remove_player($Players.get_child(turn_index))
		if player_list.size() == 0:
			end_game()
			return
		turn_index += 1
	else:
		turn_index = (turn_index + 1) % player_list.size()
	await get_tree().create_timer(0.5).timeout
	$Players.get_child(turn_index).start_turn()

func start_game():
	$ActionButtons/CaboButton.disabled = true
	await get_tree().create_timer(2).timeout
	for player in $Players.get_children():
		if player.is_human == false:
			player.memory[0] = player.hand[0]
			player.memory[1] = player.hand[1]
		if player.is_main_player:
			player.get_node('Hand').get_child(0).flip()
			player.get_node('Hand').get_child(1).flip()
			await get_tree().create_timer(3).timeout
			player.get_node('Hand').get_child(0).flip()
			player.get_node('Hand').get_child(1).flip()
	$ActionButtons/CaboButton.disabled = false
	if player_list.size() > 0:
		player_list[turn_index].start_turn()

func end_game():
	for player in $Players.get_children():
		for card in player.get_node('Hand').get_children():
			card.flip()
	print(get_winner())
	await get_tree().create_timer(5).timeout
	get_tree().reload_current_scene() 

func get_winner():
	var min_sum = 50
	var winner = null
	for player in $Players.get_children():
		var player_sum = CardSystem.get_sum(player.hand)
		if player_sum < min_sum:
			min_sum = player_sum
			winner = player
	return winner

func set_new_card(player, card):
	new_cards[player] = card
	if player.is_human:
		$Pile.enable()
		player.has_new_card = true
		for button in player.get_node('Buttons').get_children():
			button.disabled = false
	
func clear_new_card(player):
	new_cards[player] = null
	if player.is_human:
		player.has_new_card = false
		for button in player.get_node('Buttons').get_children():
			button.disabled = true

func _on_cabo_button_pressed():
	$ActionButtons/CaboButton.disabled = true
	final_round = true
	end_turn()

func _process(_delta):
	for player in $Players.get_children():
		if player.is_human == false:
			print(str(player) + str(player.hand))
			print(str(player) + str(player.memory))
