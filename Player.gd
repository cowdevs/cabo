extends Node2D

var hand = []
var can_draw := false
		
func _to_string():
	return 'Player' + str(TurnSystem.player_list.find(self) + 1)
		
func start_turn():
	can_draw = true
	
func end_turn():
	for card in hand:
		card.can_select = false
	can_draw = false

func _on_button_1_pressed():
	var card = hand[0]
	for i in hand:
		i.can_select = false
	hand[0] = TurnSystem.new_cards[self]
	TurnSystem.new_cards[self] = null
	card.can_discard = true
	card.discard()
	TurnSystem.end_turn()

func _on_button_2_pressed():
	var card = hand[1]
	for i in hand:
		i.can_select = false
	card.can_select = false
	hand[1] = TurnSystem.new_cards[self]
	TurnSystem.new_cards[self] = null
	card.can_discard = true
	card.discard()
	TurnSystem.end_turn()

func _on_button_3_pressed():
	var card = hand[2]
	for i in hand:
		i.can_select = false
	card.can_select = false
	hand[2] = TurnSystem.new_cards[self]
	TurnSystem.new_cards[self] = null
	card.can_discard = true
	card.discard()
	TurnSystem.end_turn()

func _on_button_4_pressed():
	var card = hand[3]
	for i in hand:
		i.can_select = false
	card.can_select = false
	hand[3] = TurnSystem.new_cards[self]
	TurnSystem.new_cards[self] = null
	card.can_discard = true
	card.discard()
	TurnSystem.end_turn()

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			for card in hand:
				card.flip()
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
