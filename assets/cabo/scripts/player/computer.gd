extends Player

var memory: Dictionary

func _ready():
	is_human = false
	is_main_player = false

	hand = []
	memory = {}
	can_draw = false
	has_new_card = false
	doing_action = false

	for player in Game.get_node('Players').get_children():
		memory[player] = [null, null, null, null]
	Pile.connect('action_confirm', _on_action_confirm)
	
	for button in $Control/Buttons.get_children():
		button.connect('pressed_button', _on_button_pressed)
		button.disabled = true
	
	$Control/CaboButton.hide()
	
func _process(_delta):
	print(hand)
	print(memory)

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
				await get_tree().create_timer(3).timeout
				flipping_card.flip()
			elif player.store_action == 'swap':
				var card = $Hand.get_child(i)
				card.hide()
				var fake_card = $FakeCardsComponent.get_children()[i]
				fake_card.show()
				fake_card.translate(Vector2(0, -225))
				for button in player.get_node('$Control/Buttons').get_children():
					button.disabled = false
				var index = await player.swap_action
				Game.swap(hand, i, player.hand, index)
				fake_card.translate(Vector2(0, 225))
				fake_card.hide()
				card.show()
			player.store_action = null
			Input.set_custom_mouse_cursor(arrow_cursor)
			Game.end_turn()

func set_new_card(card):
	new_card = card
	
func clear_new_card():
	new_card = null

func computer_turn():
	# draw from pile if card is 0
	if Pile.get_top_card().value == 0:
		Pile.draw_card(self)
	else:
		Deck.draw_card(self)

	await get_tree().create_timer(2).timeout
	
	# play best card
	if new_card.value == 0 and null in memory[self]: # replace 0 with null
		var index = memory[self].find(null)
		Pile.discard(hand[index])
		hand[index] = new_card
		memory[self][index] = new_card
	else:
		var maxpos = Game.maxpos(memory[self])
		if memory[self][maxpos].value > new_card.value:
			Pile.discard(hand[maxpos])
			clear_new_card()
			hand[maxpos] = new_card
			memory[self][maxpos] = new_card
		else:
			var card = new_card
			Pile.discard(new_card)
			clear_new_card()
			if card.value in range(7, 13):
				await get_tree().create_timer(1).timeout
				if card.value in [7, 8]: # peek
					if null in memory[self]:
						var index = memory[self].find(null)
						memory[self][index] = hand[index]
				elif card.value in [9, 10]: # spy
					var player_hands = memory.values()
					player_hands.sort_custom(sort_sum)
					for hand in player_hands:
						var player = memory.find_key(hand)
						if player != self:
							if null in hand:
								var index = hand.find(null)
								memory[player][index] = hand[index]
								break
				elif card.value in [11, 12]: # swap
					swap_action()
				await get_tree().create_timer(3).timeout
	Game.end_turn()

func swap_action():
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
		player_hands.sort_custom(sort_sum)
		for hand in player_hands:
			var player = memory.find_key(hand)
			if player != self:
				var max_index = Game.maxpos(memory[self])
				var min_index = Game.minpos(memory[player])
				if memory[self][max_index].value > memory[player][min_index].value:
					Game.swap(player.hand, min_index, hand, max_index)

func sort_sum(a, b):
	if Game.sum(a) < Game.sum(b):
		return true
	return false

func exchange_new_card(i):
	pass
	
func discard_new_card(i):
	pass
