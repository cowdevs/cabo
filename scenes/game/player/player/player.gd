extends Node2D

const is_player = true

var hand = []
var can_draw := false
var has_new_card := false
var doing_action := false

func _to_string():
	return 'Player' + str(TurnSystem.player_list.find(self) + 1)

func _process(_delta):
	for button in $Buttons.get_children():
		button.disabled = false if has_new_card or doing_action else true
	get_node('/root/GameScreen/Deck/DeckButton').disabled = false if not has_new_card and can_draw else true
	get_node('/root/GameScreen/Pile/PileButton').disabled = false if has_new_card or can_draw else true

func start_turn():
	can_draw = true
	
func end_turn():
	can_draw = false

func _on_button_1_pressed():
	if not doing_action:
		var card = hand[0]
		hand[0] = TurnSystem.new_cards[self]
		TurnSystem.new_cards[self] = null
		card.discard()
		CardSystem.update_pile_display()
		has_new_card = false
		TurnSystem.end_turn()
	else:
		pass

func _on_button_2_pressed():
	if not doing_action:
		var card = hand[1]
		hand[1] = TurnSystem.new_cards[self]
		TurnSystem.new_cards[self] = null
		card.discard()	
		CardSystem.update_pile_display()
		has_new_card = false
		TurnSystem.end_turn()
	else:
		pass

func _on_button_3_pressed():
	if not doing_action:
		var card = hand[2]
		hand[2] = TurnSystem.new_cards[self]
		TurnSystem.new_cards[self] = null
		card.discard()
		CardSystem.update_pile_display()
		has_new_card = false
		TurnSystem.end_turn()
	else:
		pass

func _on_button_4_pressed():
	if not doing_action:
		var card = hand[3]
		hand[3] = TurnSystem.new_cards[self]
		TurnSystem.new_cards[self] = null
		card.discard()
		CardSystem.update_pile_display()
		has_new_card = false
		TurnSystem.end_turn()
	else:
		pass
