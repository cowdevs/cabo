class_name Player
extends Node2D

signal swap(index: int)
signal cabo_called(player: Player)

var is_human: bool
var is_main_player: bool

var card_scene = preload("res://assets/cabo/scenes/card.tscn")

var arrow_cursor = load("res://assets/cabo/textures/gui/cursors/normal.aseprite")
var lens_cursor = load("res://assets/cabo/textures/gui/cursors/magnifying_glass.aseprite")
var swap_cursor = load("res://assets/cabo/textures/gui/cursors/swap.aseprite")

var hand: Array
var new_card: Card
var can_draw: bool
var has_new_card: bool
var doing_action: bool

@onready var deck_node = get_parent().get_parent().get_node('Deck')
@onready var pile_node = get_parent().get_parent().get_node('Pile')
@onready var game_node = get_parent().get_parent()

func _ready():
	is_human = true
	is_main_player = false
	
	hand = []
	can_draw = false
	has_new_card = false
	doing_action = false
	
	setup()
	
	disable_cabo_button()
	$Control.hide_buttons()

func setup() -> void:
	pile_node.connect('action_confirm', _on_action_confirm)
	
	for button in $Control/Buttons.get_children():
		button.connect('pressed_button', _on_button_pressed)
		button.disabled = true
	
	for marker in $Slots.get_children():
		var card_instance = card_scene.instantiate()
		card_instance.position = marker.position
		$Hand.add_child(card_instance)
	
	for card in $FakeCards.get_children():
		card.visible = false
	
	$TurnIndicator.hide()

func _process(_delta):
	$TurnIndicator.play()
	for button in $Control/Buttons.get_children():
		if button.is_hovered() and not button.is_disabled():
			button.get_child(0).show()
			button.get_child(0).play()
		else:
			button.get_child(0).hide()
			button.get_child(0).stop()

func _to_string():
	return 'Player'

var store_action = null

func _on_action_confirm(action, player):
	$Control.show_buttons()
	await $Control/ActionButtons/YesButton.pressed
	store_action = action
	doing_action = true
	if action == 'peek' or action == 'spy':
		Input.set_custom_mouse_cursor(lens_cursor)
	elif action == 'swap':
		Input.set_custom_mouse_cursor(swap_cursor)
	if action == 'peek':
		for button in $Control/Buttons.get_children():
			button.disabled = false

func _on_button_pressed(i):
	pile_node.disable(pile_node)
	deck_node.disable(deck_node)
	if not doing_action:
		exchange_new_card(i, self)
		game_node.end_turn(self)
	else:
		doing_action = false
		for button in $Control/Buttons.get_children():
			button.disabled = true
		if store_action == 'peek':
			var flipping_card = $Hand.get_child(i)
			flipping_card.flip()
			await get_tree().create_timer(3).timeout
			flipping_card.flip()
			store_action = null
			Input.set_custom_mouse_cursor(arrow_cursor)
			game_node.end_turn(self)
		elif store_action == 'swap':
			swap.emit(i)

func _on_cabo_button_pressed():
	disable_cabo_button()
	cabo_called.emit(self)
	game_node.end_turn(self)

func exchange_new_card(i: int, player: Player):
	pile_node.discard(player.hand[i])
	player.hand[i] = player.new_card
	if not player.is_human:
		player.memory[player][i] = player.new_card
	clear_new_card()

func set_new_card(card):
	new_card = card
	pile_node.enable(pile_node)
	deck_node.disable(pile_node)
	has_new_card = true
	for button in $Control/Buttons.get_children():
		button.disabled = false
	
func clear_new_card():
	new_card = null
	has_new_card = false
	for button in $Control/Buttons.get_children():
		button.disabled = true

func enable_cabo_button() -> void:
	$Control/CaboButton.disabled = false
	$Control/CaboButton.show()

func disable_cabo_button() -> void:
	$Control/CaboButton.disabled = true
	$Control/CaboButton.hide()
