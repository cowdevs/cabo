class_name Player
extends Node2D

const CARD = preload("res://assets/cabo/scenes/card.tscn")

const ARROW_CURSOR = preload("res://assets/cabo/textures/gui/cursors/normal.aseprite")
const LENS_CURSOR = preload("res://assets/cabo/textures/gui/cursors/magnifying_glass.aseprite")
const SWAP_CURSOR = preload("res://assets/cabo/textures/gui/cursors/swap.aseprite")

@onready var DECK = get_node("/root/Game/CenterContainer/MarginContainer/Deck")
@onready var PILE = get_node("/root/Game/CenterContainer/Pile")
@onready var GAME = get_node("/root/Game")

signal swap(index: int)
signal cabo_called(player: Player)

var is_human := true
var is_main_player := false

var hand := []
var score_added: int

var can_draw := false
var has_new_card := false
var doing_action := false

var new_card: Card

func _ready():
	setup()

func setup() -> void:
	$"../../EndPanel".connect('new_round', _on_new_round)
	PILE.connect('action_confirm', _on_action_confirm)
	
	for button in $CardButtons.get_children():
		button.connect('pressed_button', _on_button_pressed)
		button.disabled = true
	
	for marker in $Slots.get_children():
		var card_instance = CARD.instantiate()
		card_instance.position = marker.position
		$HandDisplay.add_child(card_instance)
	
	$CaboCallIcon.hide()
	$TurnIndicator.play()
	$TurnIndicator.hide()
	disable_cabo_button()
	$ActionButtons.hide_action_buttons()

func _to_string():
	return 'Player'

func _on_new_round():
	hand.clear()
	for card in $HandDisplay.get_children():
		card.face = 'BACK'

var store_action = null

func _on_action_confirm(action, _player):
	$ActionButtons.show_action_buttons()
	await $ActionButtons/YesButton.pressed
	store_action = action
	doing_action = true
	if action == 'peek' or action == 'spy':
		Input.set_custom_mouse_cursor(LENS_CURSOR)
	elif action == 'swap':
		Input.set_custom_mouse_cursor(SWAP_CURSOR)
	if action == 'peek':
		for button in $CardButtons.get_children():
			button.disabled = false

func _on_button_pressed(i):
	PILE.disable()
	DECK.disable()
	if not doing_action:
		exchange_new_card(i, self)
		GAME.end_turn(self)
	else:
		doing_action = false
		for button in $CardButtons.get_children():
			button.disabled = true
		if store_action == 'peek':
			var flipping_card = $HandDisplay.get_child(i)
			flipping_card.flip()
			await get_tree().create_timer(GAME.LONG).timeout
			flipping_card.flip()
			store_action = null
			Input.set_custom_mouse_cursor(ARROW_CURSOR)
			GAME.end_turn(self)
		elif store_action == 'swap':
			swap.emit(i)

func _on_cabo_button_pressed():
	disable_cabo_button()
	$CaboCallIcon.show()
	await get_tree().create_timer(GAME.LONG).timeout
	$CaboCallIcon.hide()
	cabo_called.emit(self)
	GAME.end_turn(self)

func exchange_new_card(i: int, player: Player):
	PILE.discard(player.hand[i])
	player.hand[i] = player.new_card
	if not player.is_human:
		player.memory[player][i] = player.new_card
	clear_new_card()

func set_new_card(card):
	new_card = card
	has_new_card = true
	for button in $CardButtons.get_children():
		button.disabled = false
	
func clear_new_card():
	new_card = null
	has_new_card = false
	for button in $CardButtons.get_children():
		button.disabled = true

func enable_cabo_button() -> void:
	$CaboButton.disabled = false
	$CaboButton.show()

func disable_cabo_button() -> void:
	$CaboButton.disabled = true
	$CaboButton.hide()
