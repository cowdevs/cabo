class_name Player
extends Node2D

const CARD = preload("res://src/card/card.tscn")

@onready var DECK = get_node("/root/Game/GameContainer/DeckContainer/Deck")
@onready var PILE = get_node("/root/Game/GameContainer/Pile")
@onready var GAME = get_node("/root/Game")

@export var game_data: GameData

signal cabo_called(player: Player)
signal index_selected(i)
signal action_confirmed(bool)

var is_player := true
var is_computer := false

var score_added: int

var is_main_player := false
var can_draw := false
var has_new_card := false

func _ready():
	setup()

func setup() -> void:
	$"../../EndPanel".connect('new_round', _on_new_round)
	PILE.connect('action', _on_action)
	
	$CaboCallIcon.hide()
	$TurnIndicator.play()
	$TurnIndicator.hide()
	disable_cabo_button()
	disable_card_buttons()
	$ActionButtons.hide_action_buttons()

func _process(_delta):
	for card in get_hand():
		if not card.card_pressed.is_connected(_on_card_pressed):
			card.connect('card_pressed', _on_card_pressed)
		if not card.card_hovered.is_connected(_on_card_hovered):
			card.connect('card_hovered', _on_card_hovered)

func _to_string():
	return 'Player'

func _on_new_round():
	for card in $Hand.get_children():
		card.queue_free()

func _on_action(action, player):
	$ActionButtons.show_action_buttons()
	var confirmed = await player.action_confirmed
	if confirmed:
		if action == 'peek' or action == 'spy':
			Input.set_custom_mouse_cursor(GAME.LENS_CURSOR)
		else:
			Input.set_custom_mouse_cursor(GAME.SWAP_CURSOR)
		
		if action == 'peek':
			enable_card_buttons()
			var selected_index = await index_selected
			disable_card_buttons()
			var flipping_card = $Hand.get_child(selected_index)
			flipping_card.flip()
			await get_tree().create_timer(GAME.LONG).timeout
			flipping_card.flip()
			GAME.end_turn()

func _on_card_pressed(i):
	index_selected.emit(i)
	if get_new_card():
		PILE.disable()
		disable_card_buttons()
		exchange_new_card(i)

func _on_card_hovered(i, is_hovered):
	if get_new_card():
		var button_hover = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		if is_hovered:
			button_hover.tween_property(get_new_card(), 'global_position', get_hand()[i].global_position + Vector2(0, -92), game_data.card_movement_speed)
		else:
			button_hover.tween_property(get_new_card(), 'position', Vector2.ZERO, game_data.card_movement_speed / 1.5)

func _on_cabo_button_pressed():
	disable_cabo_button()
	$CaboCallIcon.show()
	await get_tree().create_timer(GAME.LONG).timeout
	$CaboCallIcon.hide()
	cabo_called.emit(self)
	GAME.end_turn()

func exchange_new_card(i: int) -> void:
	if get_new_card():
		var new_card = get_new_card()
		var exchange_card = get_hand()[i]
		
		new_card.play_sound()
		var exchange_card_tween_a = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		exchange_card_tween_a.tween_property(new_card, 'position', Vector2($Hand.get_child(i).position.x - 102, 92), game_data.card_movement_speed)
		if is_player:
			new_card.flip()
		await exchange_card_tween_a.finished
		
		exchange_card.play_sound()
		var exchange_card_tween_b = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		exchange_card_tween_b.tween_property(exchange_card, 'global_position', PILE.global_position, game_data.card_movement_speed)
		exchange_card.flip()
		await exchange_card_tween_b.finished
		
		clear_new_card()
		add_hand(new_card, i)
		remove_hand(exchange_card)
		PILE.discard(exchange_card)
		if is_computer:
			self.memory[self][i] = new_card
		GAME.end_turn()

func discard_new_card() -> void:
	if get_new_card():
		var new_card = get_new_card()
		new_card.play_sound()
		if is_computer:
			var discard_card = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			discard_card.tween_property(new_card, 'global_position', PILE.global_position, game_data.card_movement_speed)
			new_card.flip()
			await discard_card.finished
		clear_new_card()
		PILE.discard(new_card)
		GAME.end_turn()

func turn():
	pass

func set_new_card(card):
	$NewCard.add_child(card)
	if is_player:
		has_new_card = true
		print('CODE REACHED')
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

func get_hand_index(i: int) -> Card:
	return get_hand()[i]

func get_new_card() -> Card:
	if $NewCard.get_child_count() > 0:
		return $NewCard.get_child(0)
	else:
		return null

func enable_cabo_button() -> void:
	$CaboButton.disabled = false
	$CaboButton.show()

func enable_card_buttons() -> void:
	for card in get_hand():
		card.enable_button()

func disable_card_buttons() -> void:
	for card in get_hand():
		card.disable_button()

func disable_cabo_button() -> void:
	$CaboButton.disabled = true
	$CaboButton.hide()
