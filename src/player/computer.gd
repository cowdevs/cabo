extends Player

var memory: Dictionary
var name_label: int
var exchange_card_risk: int
var call_cabo_risk: int

func _ready():
	is_player = false
	is_computer = true
	memory = {}
	setup()

func _process(_delta):
	exchange_card_risk = ceil(4.17891 * pow(0.954139, 0.639039 * (GAME.turn_count - 1.04579)) - 0.328834)
	call_cabo_risk = ceil(0.0137406 * pow(0.928744, -0.120108 * (GAME.turn_count + 499.996)) + 2.70425)
	for card in get_hand():
		if not card.card_pressed.is_connected(_on_card_pressed):
			card.connect('card_pressed', _on_card_pressed)
		if not card.card_hovered.is_connected(_on_card_hovered):
			card.connect('card_hovered', _on_card_hovered)

func _to_string():
	return 'Computer' + str(name_label)

func _on_action(action, player):
	var confirmed = await player.action_confirmed
	if confirmed:
		if action != 'peek':
			enable_card_buttons()
			var selected_index = await index_selected
			for i in GAME.get_players():
				i.disable_card_buttons()
			if action == 'spy':
				var flipping_card = $Hand.get_child(selected_index)
				flipping_card.flip()
				await get_tree().create_timer(game_data.long_delay).timeout
				flipping_card.flip()
			elif action == 'swap':
				player.enable_card_buttons()
				var swap_index = await player.index_selected
				player.disable_card_buttons()
				GAME.swap_card(self, selected_index, player, swap_index)
				disable_card_buttons()
			GAME.end_turn()

func _on_card_pressed(i):
	index_selected.emit(i)

func turn() -> void:
	for player in memory:
		for i in range(memory[player].size()):
			if memory[player][i] != player.get_hand()[i]:
				memory[player][i] = null
	
	if not GAME.cabo_called:
		if null not in memory[self] and GAME.sum(memory[self]) <= call_cabo_risk:
			$CaboCallIcon.show()
			await get_tree().create_timer(game_data.long_delay).timeout
			$CaboCallIcon.hide()
			cabo_called.emit(self)
			GAME.end_turn()
			return
	
	# draw from pile if card is 0
	if game_data.pile.front().value == 0:
		PILE.draw_from_pile(self)
	else:
		DECK.draw_from_deck(self)

	await get_tree().create_timer(game_data.medium_delay).timeout
	
	# play best card
	var has_unknown_card = GAME.value_in_hand(null, memory[self])
	if get_new_card().value in range(exchange_card_risk + 1) and has_unknown_card[0]:
		exchange_new_card(has_unknown_card[1])
	else:
		var maxpos = GAME.maxpos(memory[self])
		if (memory[self][maxpos].value > get_new_card().value):
			if not ((get_new_card().value in [7, 8] and null in memory[self]) and (abs(memory[self][maxpos].value - get_new_card().value) <= 2)):
				exchange_new_card(maxpos)
		else:
			var new_card = get_new_card()
			discard_new_card()
			await get_tree().create_timer(game_data.short_delay).timeout
			if new_card.value in range(7, 13):
				var sorted_players = GAME.get_sorted_players(memory)
				if new_card.value in [7, 8] and not GAME.cabo_called: # peek
					var null_in_hand = GAME.value_in_hand(null, memory[self])
					if null_in_hand[0]:
						memory[self][null_in_hand[1]] = get_hand()[null_in_hand[1]]
						await get_tree().create_timer(game_data.long_delay).timeout
				elif new_card.value in [9, 10] and not GAME.cabo_called: # spy
					for player in sorted_players:
						if player != self:
							var null_in_hand = GAME.value_in_hand(null, memory[player])
							if null_in_hand[0]:
								memory[player][null_in_hand[1]] = player.get_hand()[null_in_hand[1]]
								await get_tree().create_timer(game_data.long_delay).timeout
								break
				elif new_card.value in [11, 12]: # swap
					if GAME.cabo_called:
						var cabo_caller = GAME.cabo_caller
						var zero_in_hand = GAME.value_in_hand(0, memory[cabo_caller])
						var null_in_hand = GAME.value_in_hand(null, memory[cabo_caller])
						if zero_in_hand[0]: # if player has 0
							GAME.swap_card(cabo_caller, zero_in_hand[1], self, GAME.maxpos(memory[self])) # swap with 0
						elif null_in_hand[0]: # if there is an unknown card
							if memory[cabo_caller].count(null) >= cabo_caller.get_hand().size() / 2: # if there are more unknown cards than not
								GAME.swap_card(cabo_caller, null_in_hand[1], self, GAME.maxpos(memory[self])) # swap with first unknown card
							else:
								GAME.swap_card(cabo_caller, GAME.minpos(memory[cabo_caller]), self, GAME.maxpos(memory[self])) # swap with min known card
						else: # if all cards are known
							GAME.swap_card(cabo_caller, GAME.minpos(memory[cabo_caller]), self, GAME.maxpos(memory[self])) # swap with min known card
						await get_tree().create_timer(game_data.long_delay).timeout
					else:
						var max_index = GAME.maxpos(memory[self])
						for player in sorted_players:
							if player != self:
								if TYPE_OBJECT in memory[player]:
									var min_index = GAME.minpos(memory[player])
									if memory[self][max_index].value > memory[player][min_index].value:
										GAME.swap_card(player, min_index, self, max_index)
										await get_tree().create_timer(game_data.long_delay).timeout
										break
