class_name Player
extends Node2D

const CARD = preload("res://assets/cabo/scenes/card.tscn")

const ARROW_CURSOR = preload("res://assets/cabo/textures/gui/cursors/normal.aseprite")
const LENS_CURSOR = preload("res://assets/cabo/textures/gui/cursors/magnifying_glass.aseprite")
const SWAP_CURSOR = preload("res://assets/cabo/textures/gui/cursors/swap.aseprite")

@onready var DECK = get_node("/root/Game/GameContainer/DeckContainer/Deck")
@onready var PILE = get_node("/root/Game/GameContainer/Pile")
@onready var GAME = get_node("/root/Game")

signal swap(index: int)
signal cabo_called(player: Player)

var is_player := true
var is_computer := false

var score_added: int

var is_main_player := false
var can_draw := false
var has_new_card := false
var doing_action := false

func _ready():
	PILE.connect('button_hovered', _on_pile_button_hovered)
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
		exchange_new_card(i)
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

func _on_pile_button_hovered(yes):
	if get_new_card():
		var button_hover = create_tween().set_parallel()
		if yes:
			button_hover.tween_property(get_new_card(), 'scale', Vector2(1.1, 1.1), GAME.CARD_MOVEMENT_SPEED / 2)
			button_hover.tween_property(get_new_card(), 'global_position', PILE.global_position + Vector2(0, -28), GAME.CARD_MOVEMENT_SPEED)
		else:
			button_hover.tween_property(get_new_card(), 'scale', Vector2(1, 1), GAME.CARD_MOVEMENT_SPEED / 2)
			button_hover.tween_property(get_new_card(), 'position', Vector2.ZERO, GAME.CARD_MOVEMENT_SPEED / 2)

func _on_cabo_button_pressed():
	disable_cabo_button()
	$CaboCallIcon.show()
	await get_tree().create_timer(GAME.LONG).timeout
	$CaboCallIcon.hide()
	cabo_called.emit(self)
	GAME.end_turn(self)

func exchange_new_card(i: int) -> void:
	if get_new_card():
		var new_card = get_new_card()
		var exchange_card = get_hand()[i]
		
		var exchange_card_tween_a = create_tween()
		exchange_card_tween_a.tween_property(new_card, 'position', Vector2($Hand.get_child(i).position.x - 102, 92), GAME.CARD_MOVEMENT_SPEED)
		if is_player:
			new_card.flip()
		await exchange_card_tween_a.finished
		
		var exchange_card_tween_b = create_tween()
		exchange_card_tween_b.tween_property(exchange_card, 'global_position', PILE.global_position, GAME.CARD_MOVEMENT_SPEED)
		exchange_card.flip()
		await exchange_card_tween_b.finished
		
		clear_new_card()
		add_hand(new_card, i)
		remove_hand(exchange_card)
		PILE.discard(exchange_card)
		if is_computer:
			self.memory[self][i] = new_card
		GAME.end_turn(self)

func discard_new_card() -> void:
	if get_new_card():
		var new_card = get_new_card()
		if is_computer:
			var discard_card = create_tween()
			discard_card.tween_property(new_card, 'global_position', PILE.global_position, GAME.CARD_MOVEMENT_SPEED)
			new_card.flip()
			await discard_card.finished
		clear_new_card()
		PILE.discard(new_card)
		GAME.end_turn(self)

func set_new_card(card):
	$NewCard.add_child(card)
	if is_player:
		has_new_card = true
		enable_card_buttons()
	
func clear_new_card():
	$NewCard.remove_child(get_new_card())
	if is_player:
		has_new_card = false
		disable_card_buttons()

func add_hand(card: Card, index: int) -> void:
	$Hand.add_child(card)
	$Hand.move_child(card, index)

func remove_hand(card: Card) -> void:
	$Hand.remove_child(card)

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
