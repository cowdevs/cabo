extends Node2D

signal swap_action(index)

const is_player = true

var arrow_cursor = load("res://assets/ui/cursors/normal.png")
var lens_cursor = load("res://assets/ui/cursors/magnifying_glass.png")
var swap_cursor = load("res://assets/ui/cursors/swap.png")

var hand
var can_draw: bool
var has_new_card: bool
var doing_action: bool

func _ready():
	hand = []
	can_draw = false
	has_new_card = false
	doing_action = false
	$"../../Pile".connect('action_confirm', _on_action_confirm)
	for button in $Buttons.get_children():
		button.connect('pressed_button', _on_button_pressed)
		button.disabled = true
	for card in $FakeCards.get_children():
		card.visible = false

func _to_string():
	return 'Player' + str($"..".get_children().find(self) + 1)

func start_turn():
	can_draw = true
	$"../../ActionButtons/CaboButton".disabled = false

func find_in_hand(i):
	return $Hand.get_children()[i]

var store_action = null

func _on_action_confirm(action):
	await $"../../ActionButtons/YesButton".pressed
	store_action = action
	doing_action = true
	if action == 'peek' or action == 'spy':
		Input.set_custom_mouse_cursor(lens_cursor)
	elif action == 'swap':
		Input.set_custom_mouse_cursor(swap_cursor)	
		
	if action == 'peek':
		for button in $Buttons.get_children():
			button.disabled = false

func _on_button_pressed(i):
	if not doing_action:
		var card = find_in_hand(i)
		hand[i] = TurnSystem.new_cards[self]
		TurnSystem.clear_new_card(self)
		card.discard()
		TurnSystem.end_turn()
	else:
		doing_action = false
		for button in $Buttons.get_children():
			button.disabled = true
		if store_action == 'peek':
			var flipping_card = find_in_hand(i)
			flipping_card.flip()
			await get_tree().create_timer(3).timeout
			flipping_card.flip()
			store_action = null
			Input.set_custom_mouse_cursor(arrow_cursor)
			TurnSystem.end_turn()
		elif store_action == 'swap':
			swap_action.emit(i)
