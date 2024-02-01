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
		button.disabled = true

func _to_string():
	return 'Player' + str(TurnSystem.player_list.find(self) + 1)

func start_turn():
	can_draw = true
	
func end_turn():
	can_draw = false

var store_action = null

func _on_action_confirm(action):
	await $"../ActionButtons/YesButton".pressed
	store_action = action
	doing_action = true
	if action != 'spy':
		for button in $Buttons.get_children():
			button.disabled = false

func _on_button_pressed(i):
	if not doing_action:
		var card = hand[i]
		hand[i] = TurnSystem.new_cards[self]
		TurnSystem.new_cards[self] = null
		has_new_card = false
		for button in $Buttons.get_children():
			button.disabled = true
		card.discard()
		TurnSystem.end_turn()
	else:
		doing_action = false
		for button in $Buttons.get_children():
			button.disabled = true
		if store_action == 'peek':
			$CardDisplay.get_children()[i].flip()
			await get_tree().create_timer(3).timeout
			$CardDisplay.get_children()[i].flip()
		elif store_action == 'swap':
			pass
		store_action = null
		TurnSystem.end_turn()
		


