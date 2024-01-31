extends Node2D

const is_player = true

var hand = []
var can_draw := false
var has_new_card := false
var doing_action := false

func _ready():
	$"../Pile".connect('action_confirm', _on_action_confirm)
	for button in $Buttons.get_children():
		button.connect('pressed_button', _on_button_pressed)

func _process(_delta):
	#print('can_draw: ' + str(can_draw))
	#print('has_new_card: ' + str(has_new_card))
	#print('doing_action: ' + str(doing_action))
	for button in $Buttons.get_children():
		button.disabled = false if has_new_card or doing_action else true
	$"../Deck/DeckButton".disabled = false if not has_new_card and can_draw else true
	$"../Pile/PileButton".disabled = false if has_new_card or can_draw else true

func _to_string():
	return 'Player' + str(TurnSystem.player_list.find(self) + 1)

func start_turn():
	can_draw = true
	
func end_turn():
	can_draw = false

var Action = null

func _on_action_confirm(action):
	await $"../ActionButtons/YesButton".pressed
	Action = action
	doing_action = true

func _on_button_pressed(i):
	if not doing_action:
		var card = hand[i]
		hand[i] = TurnSystem.new_cards[self]
		TurnSystem.new_cards[self] = null
		has_new_card = false
		card.discard()
	else:
		if Action == 'peek':
			$CardDisplay.get_children()[i].flip()
			await get_tree().create_timer(3).timeout
			$CardDisplay.get_children()[i].flip()
		elif Action == 'spy':
			pass
		elif Action == 'swap':
			pass
		Action = null
		doing_action = false
	TurnSystem.end_turn()

