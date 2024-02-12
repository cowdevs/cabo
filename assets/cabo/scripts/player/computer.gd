extends Player

@export var risk_factor: int
var memory: Dictionary

func _ready():
	is_human = false
	is_main_player = false
	
	risk_factor = 4
	hand = []
	memory = {}

	Pile.connect('action_confirm', _on_action_confirm)
	
	for button in $Control/Buttons.get_children():
		button.connect('pressed_button', _on_button_pressed)
		button.disabled = true

	$Control/CaboButton.hide()
	$TurnIndicator.hide()

func _to_string():
	return 'Computer' + str($"..".get_children().find(self) + 1)

func _on_action_confirm(action):
	await $"../../ActionButtons/YesButton".pressed
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
				await get_tree().create_timer(0.1).timeout # CHANGE BACK TO 3
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
				Game.swap(hand, i, player.hand, index)
				fake_card.translate(Vector2(0, 225))
				fake_card.hide()
				card.show()
			player.store_action = null
			Input.set_custom_mouse_cursor(arrow_cursor)
			Game.end_turn(self)

func set_new_card(card):
	new_card = card
	
func clear_new_card():
	new_card = null

func computer_turn():
	if Game.sum(hand) <= 6:
		cabo_called.emit(self)
	
	# draw from pile if card is 0
	if Pile.get_top_card().value == 0:
		Pile.draw_card(self)
	else:
		Deck.draw_card(self)

	await get_tree().create_timer(0.1).timeout # CHANGE BACK TO 2
	
	# play best card
	var has_unknown_card = Game.value_in_hand(null, memory[self])
	if new_card.value in range(risk_factor + 1) and has_unknown_card[0]:
		exchange_new_card(has_unknown_card[1], self)
	else:
		var maxpos = Game.maxpos(memory[self])
		if (memory[self][maxpos].value > new_card.value) and not ((new_card.value in [7, 8] and null in memory[self]) and (abs(memory[self][maxpos].value - new_card.value) <= 2)):
			exchange_new_card(maxpos, self)
		else:
			var card = new_card
			Pile.discard(new_card)
			clear_new_card()
			if card.value in range(7, 13):
				await get_tree().create_timer(0.1).timeout # CHANGE BACK TO 1
				if card.value in [7, 8]: # peek
					if null in memory[self]:
						var index = memory[self].find(null)
						memory[self][index] = hand[index]
				elif card.value in [9, 10]: # spy
					var player_hands = memory.values()
					player_hands.sort_custom(sort_sum)
					print(player_hands)
					for hand in player_hands:
						var player = memory.find_key(hand)
						if player != self:
							var null_in_hand = Game.value_in_hand(null, hand)
							if null_in_hand[0]:
								memory[player][null_in_hand[1]] = player.hand[null_in_hand[1]]
								break
				elif card.value in [11, 12]: # swap
					if Game.cabo_called:
						var cabo_player = Game.cabo_player
						var zero_in_hand = Game.value_in_hand(0, memory[cabo_player])
						var null_in_hand = Game.value_in_hand(null, memory[cabo_player])
						if zero_in_hand[0]: # if player has 0
							Game.swap(cabo_player.hand, zero_in_hand[1], hand, Game.maxpos(memory[self])) # swap with 0
						elif null_in_hand[0]: # if there is an unknown card
							if memory[cabo_player].count(null) >= cabo_player.hand.size() / 2: # if there are more unknown cards than not
								Game.swap(cabo_player.hand, null_in_hand[1], hand, Game.maxpos(memory[self])) # swap with first unknown card
							else:
								Game.swap(cabo_player.hand, Game.minpos(memory[cabo_player]), hand, Game.maxpos(memory[self])) # swap with min known card
						else: # if all cards are known
							Game.swap(cabo_player.hand, Game.minpos(memory[cabo_player]), hand, Game.maxpos(memory[self])) # swap with min known card
					else:
						var player_hands = memory.values()
						var max_index = Game.maxpos(memory[self])
						player_hands.sort_custom(sort_sum)
						for hand in player_hands:
							var player = memory.find_key(hand)
							if player != self:
								if TYPE_OBJECT in memory[player]:
									var min_index = Game.minpos(memory[player])
									print(memory[self][max_index].value)
									print(memory[player][min_index].value)
									if memory[self][max_index].value > memory[player][min_index].value:
										Game.swap(player.hand, min_index, hand, max_index)
										break
				await get_tree().create_timer(0.1).timeout # CHANGE BACK TO 3
	Game.end_turn(self)

func sort_sum(a, b):
	if Game.sum(a) < Game.sum(b):
		return true
	return false
