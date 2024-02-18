extends Player

var memory: Dictionary
var name_label: int
var exchange_card_risk: int
var call_cabo_risk: int

func _ready():
	is_human = false
	
	hand = []
	memory = {}

	setup()

func _process(_delta):
	exchange_card_risk = ceil(4.17891 * pow(0.954139, 0.639039 * (GAME.turn_count - 1.04579)) - 0.328834)
	call_cabo_risk = ceil(0.0137406 * pow(0.928744, -0.120108 * (GAME.turn_count + 499.996)) + 2.70425)
	if not memory.is_empty():
		for player in memory:
			for i in range(memory[player].size()):
				if memory[player][i] != player.hand[i]:
					memory[player][i] = null

func _to_string():
	return 'Computer' + str(name_label)

func _on_action_confirm(action, player):
	await player.get_node('Control/ActionButtons/YesButton').pressed
	if action != 'peek':
		for button in $Control/Buttons.get_children():
			button.disabled = false

func _on_button_pressed(i):
	for player in $"..".get_children():
		if player.is_human and player.doing_action:
			for button in $Control/Buttons.get_children():
				button.disabled = true
			if player.store_action == 'spy':
				var flipping_card = $HandDisplay.get_child(i)
				flipping_card.flip()
				await get_tree().create_timer(GAME.LONG).timeout
				flipping_card.flip()
			elif player.store_action == 'swap':
				for button in player.get_node('Control/Buttons').get_children():
					button.disabled = false
				var index = await player.swap
				GAME.swap(hand, i, player.hand, index)
			player.store_action = null
			Input.set_custom_mouse_cursor(ARROW_CURSOR)
			GAME.end_turn(player)

func set_new_card(card):
	new_card = card
	
func clear_new_card():
	new_card = null

func computer_turn() -> void:
	if not GAME.cabo_called:
		if null not in memory[self] and GAME.sum(memory[self]) <= call_cabo_risk:
			$CaboCallIcon.show()
			await get_tree().create_timer(GAME.LONG).timeout
			$CaboCallIcon.hide()
			cabo_called.emit(self)
			GAME.end_turn(self)
			return
	
	# draw from pile if card is 0
	if PILE.get_top_card().value == 0:
		PILE.draw_card(self)
		PILE.update()
	else:
		DECK.draw_card(self)
		DECK.update()

	await get_tree().create_timer(GAME.MEDIUM).timeout
	
	# play best card
	var has_unknown_card = GAME.value_in_hand(null, memory[self])
	if new_card.value in range(exchange_card_risk + 1) and has_unknown_card[0]:
		exchange_new_card(has_unknown_card[1], self)
	else:
		var maxpos = GAME.maxpos(memory[self])
		if (memory[self][maxpos].value > new_card.value) and not ((new_card.value in [7, 8] and null in memory[self]) and (abs(memory[self][maxpos].value - new_card.value) <= 2)):
			exchange_new_card(maxpos, self)
		else:
			var card = new_card
			PILE.discard(new_card)
			clear_new_card()
			await get_tree().create_timer(GAME.SHORT).timeout
			if card.value in range(7, 13):
				var sorted_players = GAME.get_sorted_players(memory)
				if card.value in [7, 8] and not GAME.cabo_called: # peek
					var null_in_hand = GAME.value_in_hand(null, memory[self])
					if null_in_hand[0]:
						memory[self][null_in_hand[1]] = hand[null_in_hand[1]]
						await get_tree().create_timer(GAME.LONG).timeout
				elif card.value in [9, 10] and not GAME.cabo_called: # spy
					for player in sorted_players:
						if player != self:
							var null_in_hand = GAME.value_in_hand(null, memory[player])
							if null_in_hand[0]:
								memory[player][null_in_hand[1]] = player.hand[null_in_hand[1]]
								await get_tree().create_timer(GAME.LONG).timeout
								break
				elif card.value in [11, 12]: # swap
					if GAME.cabo_called:
						var cabo_caller = GAME.cabo_caller
						var zero_in_hand = GAME.value_in_hand(0, memory[cabo_caller])
						var null_in_hand = GAME.value_in_hand(null, memory[cabo_caller])
						if zero_in_hand[0]: # if player has 0
							GAME.swap(cabo_caller.hand, zero_in_hand[1], hand, GAME.maxpos(memory[self])) # swap with 0
						elif null_in_hand[0]: # if there is an unknown card
							if memory[cabo_caller].count(null) >= cabo_caller.hand.size() / 2: # if there are more unknown cards than not
								GAME.swap(cabo_caller.hand, null_in_hand[1], hand, GAME.maxpos(memory[self])) # swap with first unknown card
							else:
								GAME.swap(cabo_caller.hand, GAME.minpos(memory[cabo_caller]), hand, GAME.maxpos(memory[self])) # swap with min known card
						else: # if all cards are known
							GAME.swap(cabo_caller.hand, GAME.minpos(memory[cabo_caller]), hand, GAME.maxpos(memory[self])) # swap with min known card
						await get_tree().create_timer(GAME.LONG).timeout
					else:
						var max_index = GAME.maxpos(memory[self])
						for player in sorted_players:
							if player != self:
								if TYPE_OBJECT in memory[player]:
									var min_index = GAME.minpos(memory[player])
									if memory[self][max_index].value > memory[player][min_index].value:
										GAME.swap(player.hand, min_index, hand, max_index)
										await get_tree().create_timer(GAME.LONG).timeout
										break
	GAME.end_turn(self)
