extends Node2D

const PLAYER = preload("res://assets/cabo/scenes/player/player.tscn")
const COMPUTER = preload("res://assets/cabo/scenes/player/computer.tscn")

var turn_list := []
var turn_index := 0
var cabo_called := false
var cabo_caller: Player

var num_players = 4

func _ready():
	$Players.add_child(PLAYER.instantiate())
	for i in range(num_players - 1):
		$Players.add_child(COMPUTER.instantiate())
	
	for player in $Players.get_children():
		Scoreboard.set_score(0, player)
		
	set_player_positions()
	
	$EndPanel.connect('new_round', _on_new_round)
	
	for player in $Players.get_children():
		player.connect('cabo_called', _on_cabo_called)
	
	start_round()

func _process(_delta):
	if $Deck.cards.size() == 0:
		$Deck.cards.append_array($Pile.cards)
		$Pile.cards = $Pile.cards.slice(-1)
		$Deck.shuffle()

func set_player_positions():
	var positions = [Vector2(800, 1050), Vector2(800, 150)] if $Players.get_child_count() == 2 else [Vector2(800, 1050), Vector2(150, 600), Vector2(800, 150), Vector2(1450, 600)]
	var rotations = [0, PI] if $Players.get_child_count() == 2 else [0, PI / 2, PI, -(PI / 2)]
	for i in range($Players.get_child_count()):
		$Players.get_child(i).position = positions[i]
		$Players.get_child(i).rotation = rotations[i]

func _on_cabo_called(player):
	$Deck.disable()
	$Pile.disable()
	cabo_called = true
	cabo_caller = player

func _on_new_round():
	turn_index = 0
	cabo_called = false
	start_round()

func start_round():
	
	$EndPanel.hide()
	
	for player in $Players.get_children():
		turn_list.append(player)
		for i in range(4):
			$Deck.deal_card(player)
	
	$Players.get_child(0).is_main_player = true
	
	var first_card = $Deck.pop_top_card()
	$Pile.discard(first_card)

	$Deck.update()
	$Pile.update()
	
	await get_tree().create_timer(2).timeout
	
	for player in $Players.get_children():
		if not player.is_human:
			for opp in $Players.get_children():
				player.memory[opp] = [null, null, null, null] if opp != player else [player.hand[0], player.hand[1], null, null]
		if player.is_main_player:
			player.get_node('Hand').get_child(0).flip()
			player.get_node('Hand').get_child(1).flip()
			await get_tree().create_timer(3).timeout
			player.get_node('Hand').get_child(0).flip()
			player.get_node('Hand').get_child(1).flip()
	await get_tree().create_timer(1).timeout
	start_turn(turn_list[turn_index])

var current_player: Player

func start_turn(player):
	current_player = player
	if player.is_human:
		$Deck.enable()
		$Pile.enable()
		player.enable_cabo_button()
	player.can_draw = true
	player.get_node('TurnIndicator').show()
	if not player.is_human:
		player.computer_turn()

func end_turn(player):
	await get_tree().create_timer(0.5).timeout
	player.get_node('TurnIndicator').hide()
	player.disable_cabo_button()
	if cabo_called:
		turn_list.erase($Players.get_child(turn_index))
		if turn_list.size() == 0:
			end_round()
			return
		turn_index += 1
	else:
		turn_index = (turn_index + 1) % turn_list.size()
	start_turn($Players.get_child(turn_index))

func end_round():
	for player in $Players.get_children():
		for card in player.get_node('Hand').get_children():
			card.flip()
	$EndPanel.calculate_scores()
	await get_tree().create_timer(5).timeout
	$EndPanel.display_scoreboard()

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

func value_in_hand(value, list) -> Array: # [bool, index]
	for i in range(list.size()):
		if (value == null and list[i] == null) or (value != null and list[i] != null and list[i].value == value):
			return [true, i]
	return [false, null]

func get_sorted_players(dict: Dictionary) -> Array:
	var players = []
	var nums = [INF]
	for player in dict:
		nums.sort()
		var num = sum(dict[player]) if typeof(dict[player]) == TYPE_ARRAY else dict[player]
		if not nums.is_empty():
			for i in range(nums.size()):
				if num < nums[i]:
					players.insert(i, player)
					break
		else:
			players.append(player)
		nums.append(num)
	return players
