extends Node2D

const is_player = false

var arrow_cursor = load("res://assets/textures/ui/cursors/normal.png")
var lens_cursor = load("res://assets/textures/ui/cursors/magnifying_glass.png")
var swap_cursor = load("res://assets/textures/ui/cursors/swap.png")

var hand
var can_draw: bool

func _ready():
	hand = []
	can_draw = false
	$"../../Pile".connect('action_confirm', _on_action_confirm)
	for button in $Buttons.get_children():
		button.connect('pressed_button', _on_button_pressed)
		button.disabled = true
	for card in $FakeCards.get_children():
		card.visible = false

func _to_string():
	return 'Computer' + str($"..".get_children().find(self) + 1)

func find_in_hand(i):
	return $Hand.get_children()[hand.find(hand[i])]

func start_turn():
	can_draw = true
	
	# draw from pile if card is 0
	if CardSystem.get_card(CardSystem.pile).value == 0:
		CardSystem.deal_card(CardSystem.pile, self)
	else:
		CardSystem.deal_card(CardSystem.deck, self)

	await get_tree().create_timer(2).timeout
	
	# play best card
	if CardSystem.get_best_card(hand, self) != null:
		var card = CardSystem.get_best_card(hand, self)
		hand[hand.find(card)] = TurnSystem.new_cards[self]
		TurnSystem.clear_new_card(self)
		card.discard()
		TurnSystem.end_turn()
	else:
		if TurnSystem.new_cards[self] != null:
			var card = TurnSystem.new_cards[self]
			card.discard()
			if card.value in range(7, 13):
				if card.value in [7, 8]:
					pass
				elif card.value in [9, 10]:
					pass
				elif card.value in [11, 12]:
					pass
			TurnSystem.clear_new_card(self)
			TurnSystem.end_turn()

func _on_action_confirm(action):
	await $"../../ActionButtons/YesButton".pressed
	
	if action != 'peek':
		for button in $Buttons.get_children():
			button.disabled = false

func _on_button_pressed(i):
	for player in $"..".get_children():
		if player.is_player and player.doing_action:
			for button in $Buttons.get_children():
				button.disabled = true
			if player.store_action == 'spy':
				var flipping_card = find_in_hand(i)
				flipping_card.flip()
				await get_tree().create_timer(3).timeout
				flipping_card.flip()
			elif player.store_action == 'swap':
				var card = find_in_hand(i)
				card.hide()
				var fake_card = $FakeCards.get_children()[i]
				fake_card.show()
				fake_card.translate(Vector2(0, -225))
				for button in player.get_node('Buttons').get_children():
					button.disabled = false
				var index = await player.swap_action
				var temp = hand[i]
				hand[i] = player.hand[index]
				player.hand[index] = temp
				fake_card.translate(Vector2(0, 225))
				fake_card.hide()
				card.show()
			player.store_action = null
			Input.set_custom_mouse_cursor(arrow_cursor)
			TurnSystem.end_turn()
