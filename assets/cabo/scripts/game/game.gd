extends Node2D

var player_scene = preload("res://assets/cabo/scenes/player/player.tscn")
var computer_scene = preload("res://assets/cabo/scenes/player/computer.tscn")

var num_computers = 1

func _ready():
	player_list = []
	turn_index = 0
	cabo_called = false
	
	$EndPanel.hide()
	
	$Players.add_child(player_scene.instantiate())
	for i in range(num_computers):
		$Players.add_child(computer_scene.instantiate())
	
	$Players.get_child(0).is_main_player = true
	
	set_player_positions()
		
	for player in $Players.get_children():
		player.connect('cabo_called', _on_cabo_called)
		player_list.append(player)
		for i in range(4):
			$Deck.deal_card(player)
	
	var first_card = $Deck.pop_top_card()
	$Pile.discard(first_card)

	$Deck.update()
	$Pile.update()
	
	$ActionButtons.hide_buttons()
	
	await get_tree().create_timer(2).timeout	
	start_round()

func _process(_delta):
	if $Deck.cards.size() == 0:
		$Deck.cards.append_array($Pile.cards)
		$Pile.cards = $Pile.cards.slice(-1)
		$Deck.shuffle()
		
func set_player_positions():
	var positions = [Vector2(800, 1050), Vector2(800, 150)] if $Players.get_child_count() == 2 else [Vector2(800, 1050), Vector2(150, 600), Vector2(800, 150), Vector2(1450, 600)]
	var rotations = [0, PI] if $Players.get_child_count() == 2 else [0, PI / 2, PI, -(PI / 2)]
	for i in $Players.get_child_count():
		$Players.get_child(i).position = positions[i]
		$Players.get_child(i).rotation = rotations[i]

var player_list
var turn_index: int
var cabo_called: bool
var cabo_player: Player

func _on_cabo_called(player):
	cabo_called = true
	cabo_player = player

func start_round():
	for player in $Players.get_children():
		if player.is_human == false:
			player.memory[player][0] = player.hand[0]
			player.memory[player][1] = player.hand[1]
		if player.is_main_player:
			player.get_node('Hand').get_child(0).flip()
			player.get_node('Hand').get_child(1).flip()
			await get_tree().create_timer(3).timeout
			player.get_node('Hand').get_child(0).flip()
			player.get_node('Hand').get_child(1).flip()
	start_turn(player_list[turn_index])

func start_turn(player):
	if player.is_human:
		$Deck.enable()
		$Pile.enable()
		player.get_node("Control/CaboButton").disabled = false
	player.can_draw = true
	if not player.is_human:
		player.computer_turn()

func end_turn():
	if cabo_called:
		player_list.erase($Players.get_child(turn_index))
		if player_list.size() == 0:
			end_round()
			return
		turn_index += 1
	else:
		turn_index = (turn_index + 1) % player_list.size()
	await get_tree().create_timer(0.5).timeout
	start_turn($Players.get_child(turn_index))

func end_round():
	for player in $Players.get_children():
		for card in player.get_node('Hand').get_children():
			card.flip()
	print(get_winner())
	await get_tree().create_timer(5).timeout
	$"EndPanel/Animation".play('popup')

func get_winner():
	var min_sum = 50
	var winner = null
	for player in $Players.get_children():
		var player_sum = sum(player.hand)
		if player_sum < min_sum:
			min_sum = player_sum
			winner = player
	return winner

func swap(list_a: Array, a_index: int, list_b: Array, b_index: int) -> void:
	var temp = list_a[a_index]
	list_a[a_index] = list_b[b_index]
	list_b[b_index] = temp

# RETURN METHODS
func sum(list) -> int:
	var total = 0
	for i in list:
		if i != null:
			total += i.value
	return total

func minpos(list: Array) -> int:
	var list_values = []
	for card in list:
		if card == null:
			list_values.append(INF)
		else:
			list_values.append(card.value)
	return list_values.find(list_values.min())
	
func maxpos(list: Array) -> int:
	var list_values = []
	for card in list:
		if card == null:
			list_values.append(-INF)
		else:
			list_values.append(card.value)
	return list_values.find(list_values.max())

func value_in_hand(value, list) -> Array: # bool, index
	for i in range(list.size()):
		if (list[i].value == value and value != null) or (list[i] == value and value == null):
			return [true, i]
	return [false, null]

