extends Node2D

const is_human = false
var is_main_player = false

var arrow_cursor = load("res://assets/textures/ui/cursors/normal.png")
var lens_cursor = load("res://assets/textures/ui/cursors/magnifying_glass.png")
var swap_cursor = load("res://assets/textures/ui/cursors/swap.png")

@onready var main = get_node('/root/Main')

var hand
var memory
var opponent_memory
var can_draw: bool

func _ready():
	hand = []
	memory = [null, null, null, null]
	opponent_memory = {}
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
	if main.new_cards[self].value == 0 and CardSystem.all_int(memory):
		for i in range(hand.size()):
			if memory[i] == null:
				hand[i] = main.new_cards[self]
				memory[i] = main.new_cards[self]
				break
	else:
		var best_card = CardSystem.get_best_card(memory, self)
		if best_card != null:
			var best_card_index = hand.find(best_card)
			hand[best_card_index] = main.new_cards[self]
			memory[best_card_index] = main.new_cards[self]
			main.clear_new_card(self)
			best_card.discard()
		else:
			if main.new_cards[self] != null:
				var card = main.new_cards[self]
				card.discard()
				if card.value in range(7, 13):
					if card.value in [7, 8]:
						pass
					elif card.value in [9, 10]:
						pass
					elif card.value in [11, 12]:
						pass
				main.clear_new_card(self)
	main.end_turn()

func _on_action_confirm(action):
	await $"../../ActionButtons/YesButton".pressed
	
	if action != 'peek':
		for button in $Buttons.get_children():
			button.disabled = false

func _on_button_pressed(i):
	for player in $"..".get_children():
		if player.is_human and player.doing_action:
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
			main.end_turn()
