extends Node2D

const PLAYER = preload("res://src/player/player.tscn")
const COMPUTER = preload("res://src/player/computer.tscn")

const ARROW_CURSOR = preload("res://assets/textures/gui/cursors/normal.aseprite")
const LENS_CURSOR = preload("res://assets/textures/gui/cursors/magnifying_glass.aseprite")
const SWAP_CURSOR = preload("res://assets/textures/gui/cursors/swap.aseprite")

@export var game_data: GameData

var turn_list := []
var turn_index: int
var cabo_called := false
var cabo_caller: Player

func _ready():
	%Players.add_child(PLAYER.instantiate())
	for i in range(game_data.num_players - 1):
		var computer = COMPUTER.instantiate()
		%Players.add_child(computer)
		computer.name_label = i + 1

	set_player_positions()
	
	%Players.get_child(0).is_main_player = true
	
	%EndPanel.connect('new_round', _on_new_round)
	
	for player in %Players.get_children():
		Scoreboard.set_score(0, player)
		player.connect('cabo_called', _on_cabo_called)
	
	start_round()

func _process(_delta):
	if game_data.deck.size() == 0:
		game_data.deck = game_data.pile.slice(1)
		game_data.pile = game_data.pile.slice(0, 1)
		game_data.deck.shuffle()
		%Deck.update()
		%Pile.update()

func set_player_positions():
	var positions := [Vector2(0, 184), Vector2(-234, 0), Vector2(0, -184), Vector2(234, 0)]
	var cabo_call_icon_positions = [Vector2(0, -57), Vector2(-11, -71), Vector2(0, -57), Vector2(11, -71)]
	var rotations := [0, PI / 2, PI, -(PI / 2)]
	var indexes
	if %Players.get_child_count() == 2:
		indexes = [0, 2]
	elif %Players.get_child_count() == 4:
		indexes = [0, 1, 2, 3]
	for i in range(%Players.get_child_count()):
		%Players.get_child(i).position = positions[indexes[i]]
		%Players.get_child(i).rotation = rotations[indexes[i]]
		%Players.get_child(i).get_node('CaboCallIcon').position = cabo_call_icon_positions[indexes[i]]
		%Players.get_child(i).get_node('CaboCallIcon').rotation = -rotations[indexes[i]]
		%Players.get_child(i).get_node('CaboCallIcon').frame = indexes[i]

func _on_cabo_called(player):
	%Deck.disable()
	%Pile.disable()
	cabo_called = true
	cabo_caller = player

var turn_count := 0

func _on_new_round():
	turn_count = 0
	cabo_called = false
	start_round()

func start_round():
	%EndPanel.hide()

	await get_tree().create_timer(game_data.very_short_delay).timeout
	
	var main_player: Player
	for player in get_players():
		turn_list.append(player)
		for i in range(4):
			await %Deck.deal_card(player)
		if player.is_computer:
			for opp in %Players.get_children():
				if opp != player:
					player.memory[opp] = [null, null, null, null]
				else:
					player.memory[opp] = [player.get_hand_index(0), player.get_hand_index(1), null, null]
		if player.is_main_player:
			main_player = player
	
	await get_tree().create_timer(game_data.short_delay).timeout
	
	main_player.get_node('Hand').get_child(0).flip()
	main_player.get_node('Hand').get_child(1).flip()
	await get_tree().create_timer(game_data.long_delay).timeout
	main_player.get_node('Hand').get_child(0).flip()
	main_player.get_node('Hand').get_child(1).flip()
	
	await get_tree().create_timer(game_data.short_delay).timeout
	
	%Deck.discard_first_card()
	
	await get_tree().create_timer(game_data.short_delay).timeout
	
	turn_index = 0 # randi_range(0, %Players.get_child_count() - 1)
	start_turn(turn_list[turn_index])

var current_player: Player

func start_turn(player):
	turn_count += 1
	current_player = player
	if player.is_player:
		%Deck.enable()
		%Pile.enable()
		player.enable_cabo_button()
	player.can_draw = true
	player.get_node('TurnIndicator').show()
	if player.is_computer:
		player.turn()

func end_turn():
	Input.set_custom_mouse_cursor(ARROW_CURSOR)
	await get_tree().create_timer(game_data.very_short_delay).timeout
	current_player.get_node('TurnIndicator').hide()
	current_player.disable_cabo_button()
	if cabo_called:
		turn_list.erase(%Players.get_child(turn_index))
		if turn_list.size() == 0:
			end_round()
			return
	turn_index = (turn_index + 1) % %Players.get_child_count()
	start_turn(%Players.get_child(turn_index))

func end_round():
	for player in %Players.get_children():
		for card in player.get_node('Hand').get_children():
			card.flip()
	await get_tree().create_timer(game_data.very_long_delay).timeout
	%EndPanel.display_scoreboard()

func swap_card(player_a: Player, index_a: int, player_b: Player, index_b: int) -> void:
	var card_a = player_a.get_hand_index(index_a)
	var card_b = player_b.get_hand_index(index_b)
	var swap_card_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	swap_card_tween.tween_property(card_a, 'global_position', card_b.global_position, game_data.card_movement_speed)
	swap_card_tween.tween_property(card_b, 'global_position', card_a.global_position, game_data.card_movement_speed)
	await swap_card_tween.finished
	player_a.remove_hand(card_a)
	player_b.remove_hand(card_b)
	player_a.add_hand(card_b, index_a)
	player_b.add_hand(card_a, index_b)

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
	var arr = [INF]
	for player in dict:
		arr.sort()
		var n = sum(dict[player]) if typeof(dict[player]) == TYPE_ARRAY else dict[player]
		for i in range(arr.size()):
			if n < arr[i]:
				players.insert(i, player)
				break
		arr.append(n)
	return players

func get_players() -> Array:
	return %Players.get_children()
