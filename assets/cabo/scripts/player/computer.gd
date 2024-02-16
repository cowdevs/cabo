extends Player

@export var risk_factor: int
var memory: Dictionary

func _ready():
	is_human = false
	
	risk_factor = 2
	hand = []
	memory = {}

	setup()

func _to_string():
	return 'Computer' + str($"..".get_children().find(self))

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
				var flipping_card = $Hand.get_child(i)
				flipping_card.flip()
				await get_tree().create_timer(3).timeout
				flipping_card.flip()
			elif player.store_action == 'swap':
				var card = $Hand.get_child(i)
				card.hide()
				var fake_card = $FakeCards.get_children()[i]
				fake_card.show()
				fake_card.translate(Vector2(0, -225))
				for button in player.get_node('Control/Buttons').get_children():
					button.disabled = false
				var index = await player.swap
				game_node.swap(hand, i, player.hand, index)
				fake_card.translate(Vector2(0, 225))
				fake_card.hide()
				card.show()
			player.store_action = null
			Input.set_custom_mouse_cursor(ARROW_CURSOR)
			game_node.end_turn(player)

func set_new_card(card):
	new_card = card
	
func clear_new_card():
	new_card = null

func computer_turn():
	if game_node.sum(hand) <= 6:
		cabo_called.emit(self)
	
	# draw from pile if card is 0
	if pile_node.get_top_card().value == 0:
		pile_node.draw_card(self)
		pile_node.update()
	else:
		deck_node.draw_card(self)
		deck_node.update()

	await get_tree().create_timer(2).timeout
	
	# play best card
	var has_unknown_card = game_node.value_in_hand(null, memory[self])
	if new_card.value in range(risk_factor + 1) and has_unknown_card[0]:
		exchange_new_card(has_unknown_card[1], self)
	else:
		var maxpos = game_node.maxpos(memory[self])
		if (memory[self][maxpos].value > new_card.value) and not ((new_card.value in [7, 8] and null in memory[self]) and (abs(memory[self][maxpos].value - new_card.value) <= 2)):
			exchange_new_card(maxpos, self)
		else:
			var card = new_card
			pile_node.discard(new_card)
			clear_new_card()
			await get_tree().create_timer(1).timeout
			if card.value in range(7, 13):
				var sorted_memory = game_node.get_sorted_players(memory)
				if card.value in [7, 8]: # peek
					if not game_node.cabo_called:
						if null in memory[self]:
							var index = memory[self].find(null)
							memory[self][index] = hand[index]
							await get_tree().create_timer(3).timeout
				elif card.value in [9, 10]: # spy
					for player in sorted_memory:
						if player != self:
							var null_in_hand = game_node.value_in_hand(null, memory[player])
							if null_in_hand[0]:
								memory[player][null_in_hand[1]] = player.hand[null_in_hand[1]]
								await get_tree().create_timer(3).timeout
								break
				elif card.value in [11, 12]: # swap
					if game_node.cabo_called:
						var cabo_caller = game_node.cabo_caller
						var zero_in_hand = game_node.value_in_hand(0, memory[cabo_caller])
						var null_in_hand = game_node.value_in_hand(null, memory[cabo_caller])
						if zero_in_hand[0]: # if player has 0
							game_node.swap(cabo_caller.hand, zero_in_hand[1], hand, game_node.maxpos(memory[self])) # swap with 0
						elif null_in_hand[0]: # if there is an unknown card
							if memory[cabo_caller].count(null) >= cabo_caller.hand.size() / 2: # if there are more unknown cards than not
								game_node.swap(cabo_caller.hand, null_in_hand[1], hand, game_node.maxpos(memory[self])) # swap with first unknown card
							else:
								game_node.swap(cabo_caller.hand, game_node.minpos(memory[cabo_caller]), hand, game_node.maxpos(memory[self])) # swap with min known card
						else: # if all cards are known
							game_node.swap(cabo_caller.hand, game_node.minpos(memory[cabo_caller]), hand, game_node.maxpos(memory[self])) # swap with min known card
						await get_tree().create_timer(3).timeout
					else:
						var max_index = game_node.maxpos(memory[self])
						for player in sorted_memory:
							if player != self:
								#print('CODE REACHED: ' + str(player) + str(memory[player]))
								if TYPE_OBJECT in memory[player]:
									var min_index = game_node.minpos(memory[player])
									if memory[self][max_index].value > memory[player][min_index].value:
										game_node.swap(player.hand, min_index, hand, max_index)
										await get_tree().create_timer(3).timeout
										break
								#print('SWAP SKIPPED')
	game_node.end_turn(self)
