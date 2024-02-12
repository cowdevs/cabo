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

@onready var Deck = $"../../Deck"
@onready var Pile = $"../../Pile"
@onready var Game = $"../.."

func _ready():
	is_human = true
	is_main_player = false
	
	hand = []
	can_draw = false
	has_new_card = false
	doing_action = false
	
	Pile.connect('action_confirm', _on_action_confirm)
	
	for button in $Control/Buttons.get_children():
		button.connect('pressed_button', _on_button_pressed)
		button.disabled = true
	
	$Control/CaboButton.disabled = true

func _to_string():
	return 'Player' + str($"..".get_children().find(self) + 1)

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
	Pile.disable()
	Deck.disable()
	if not doing_action:
		var card = $Hand.get_child(i)
		hand[i] = new_card
		clear_new_card()
		Pile.discard(card)
		get_node('/root/Game').end_turn()
	else:
		doing_action = false
		for button in $Buttons.get_children():
			button.disabled = true
		if store_action == 'peek':
			var flipping_card = $Hand.get_child(i)
			flipping_card.flip()
			await get_tree().create_timer(3).timeout
			flipping_card.flip()
			store_action = null
			Input.set_custom_mouse_cursor(arrow_cursor)
			get_node('/root/Game').end_turn()
		elif store_action == 'swap':
			swap.emit(i)

func _on_cabo_button_pressed():
	$Control/CaboButton.disabled = true
	cabo_called.emit(self)
	Game.end_turn()

func set_new_card(card):
	new_card = card
	Pile.enable()
	Deck.disable()
	has_new_card = true
	for button in $Control/Buttons.get_children():
		button.disabled = false
	
func clear_new_card():
	new_card = null
	has_new_card = false
	for button in $Control/Buttons.get_children():
		button.disabled = true
