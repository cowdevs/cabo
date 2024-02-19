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

var score_added: int

var can_draw := false
var has_new_card := false
var doing_action := false

func _ready():
	setup()

func setup() -> void:
	$"../../EndPanel".connect('new_round', _on_new_round)
	PILE.connect('action_confirm', _on_action_confirm)
	
	for button in $CardButtons.get_children():
		button.connect('pressed_button', _on_button_pressed)

	$CaboCallIcon.hide()
	$TurnIndicator.play()
	$TurnIndicator.hide()
	disable_cabo_button()
	disable_card_buttons()
	$ActionButtons.hide_action_buttons()

func _to_string():
	return 'Player'

func _on_new_round():
	for card in $Hand.get_children():
		card.queue_free()

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
		enable_card_buttons()

func _on_button_pressed(i):
	disable_card_buttons()
	if not doing_action:
		exchange_new_card(i, self)
		GAME.end_turn(self)
	else:
		doing_action = false
		if store_action == 'peek':
			var flipping_card = $Hand.get_child(i)
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

func exchange_new_card(i: int, player: Player) -> void:
	PILE.discard(player.get_hand()[i])
	player.get_hand()[i] = player.get_new_card()
	if not player.is_human:
		player.memory[player][i] = player.get_new_card()
	player.clear_new_card()

func discard_new_card() -> void:
	PILE.discard(get_new_card())

func set_new_card(card):
	$NewCard.add_child(card)
	if is_human:
		has_new_card = true
		enable_card_buttons()
	
func clear_new_card():
	$NewCard.remove_child(get_new_card())
	if is_human:
		has_new_card = true
		disable_card_buttons()

func add_hand(card: Card) -> void:
	$Hand.add_child(card)

func get_hand() -> Array:
	return $Hand.get_children()

func get_new_card() -> Card:
	if $NewCard.get_child_count() > 0:
		return $NewCard.get_child(0)
	else:
		return null

func enable_cabo_button() -> void:
	$CaboButton.disabled = false
	$CaboButton.show()

func enable_card_buttons() -> void:
	for button in $CardButtons.get_children():
		button.disabled = false

func disable_card_buttons() -> void:
	for button in $CardButtons.get_children():
		button.disabled = true

func disable_cabo_button() -> void:
	$CaboButton.disabled = true
	$CaboButton.hide()
