extends Node2D

const is_player = false

var hand = []
var memory = []
var can_draw := false

func _ready():
	$"../Pile".connect('action_confirm', _on_action_confirm)
	for button in $Buttons.get_children():
		button.connect('pressed_button', _on_button_pressed)
		button.disabled = true

func _to_string():
	return 'Computer' + str(TurnSystem.player_list.find(self) + 1)

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
		TurnSystem.new_cards[self] = null
		card.discard()
		TurnSystem.end_turn()
	else:
		if TurnSystem.new_cards[self] != null:
			TurnSystem.new_cards[self].discard()
			if TurnSystem.new_cards[self].value in range(7, 13):
				if TurnSystem.new_cards[self].value in [7, 8]:
					pass
				elif TurnSystem.new_cards[self].value in [9, 10]:
					pass
				elif TurnSystem.new_cards[self].value in [11, 12]:
					pass
			TurnSystem.new_cards[self] = null
			TurnSystem.end_turn()
	
func end_turn():
	can_draw = false

func _on_action_confirm(action):
	await $"../ActionButtons/YesButton".pressed
	if action != 'peek':
		for button in $Buttons.get_children():
			button.disabled = false

func _on_button_pressed(i):
	for player in TurnSystem.player_list:
		if player.is_player and player.doing_action:
			for button in $Buttons.get_children():
				button.disabled = true
			if player.store_action == 'spy':
				$CardDisplay.get_children()[i].flip()
				await get_tree().create_timer(3).timeout
				$CardDisplay.get_children()[i].flip()
			elif player.store_action == 'swap':
				pass
			player.store_action = null
			TurnSystem.end_turn()

