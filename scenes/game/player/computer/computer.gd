extends Node2D

const is_player = false

var hand = []
var memory = []
var can_draw := false

func _to_string():
	return 'Computer' + str(TurnSystem.player_list.find(self) + 1)
	
func _process(_delta):
	for button in $Buttons.get_children():
		button.disabled = true

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
					_on_peek_action()
				elif TurnSystem.new_cards[self].value in [9, 10]:
					_on_spy_action()
				elif TurnSystem.new_cards[self].value in [11, 12]:
					_on_swap_action()
			TurnSystem.new_cards[self] = null
			TurnSystem.end_turn()
	
func end_turn():
	can_draw = false

func _on_peek_action():
	print('PEEK WORKING FOR COMPUTER!')
	
func _on_spy_action():
	print('SPY WORKING FOR COMPUTER!')
	
func _on_swap_action():
	print('SWAP WORKING FOR COMPUTER!')
	
