extends Node2D

var hand = []
var memory = []
var can_draw := false

func _to_string():
	return 'Computer' + str(TurnSystem.player_list.find(self) + 1)

func start_turn():
	can_draw = true
	if Cards.get_card(Cards.pile).value == 0:
		Cards.deal_card(Cards.pile, self)
	else:
		Cards.deal_card(Cards.deck, self)

	await get_tree().create_timer(0.25).timeout
	
	if Cards.get_best_card(hand, self) != null:
		var card = Cards.get_best_card(hand, self)
		hand[hand.find(card)] = TurnSystem.new_cards[self]
		TurnSystem.new_cards[self] = null
		card.can_discard = true
		card.discard()
		TurnSystem.end_turn()
	else:
		if TurnSystem.new_cards[self] != null:
			TurnSystem.new_cards[self].discard()
		
			# check actions
			if TurnSystem.new_cards[self].value in [7, 8]:
				print('PEEK ACTION')
			if TurnSystem.new_cards[self].value in [9, 10]:
				print('SPY ACTION')
			if TurnSystem.new_cards[self].value in [11, 12]:
				print('SWAP ACTION')
		
			TurnSystem.new_cards[self] = null
			TurnSystem.end_turn()
	
func end_turn():
	for card in hand:
		card.can_select = false
	can_draw = false
