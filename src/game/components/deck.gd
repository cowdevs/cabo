class_name Deck
extends Control

const CARD = preload("res://src/card/card.tscn")

@onready var GAME = get_node("/root/Game")
@export var game_data: GameData
@onready var GAME_CONTAINER = get_node("/root/Game/GameContainer")

func _ready():
	$"../../EndPanel".connect('new_round', _on_new_round)
	$Card.connect('card_pressed', _on_card_pressed)
	$Card.face = 'BACK'
	game_data.create_deck()
	game_data.deck.shuffle()
	disable()
	update()

func _process(_delta):
	update()

func _to_string():
	return str(game_data.deck)

func _on_new_round():
	game_data.create_deck()
	game_data.deck.shuffle()
	disable()
	update()

func _on_card_pressed(_i):
	var player = GAME.current_player
	if player:
		if player.is_player:
			if player.can_draw:
				draw_from_deck(player)
				player.disable_cabo_button()
				update()
				disable()

func discard_first_card() -> void:
	if game_data.deck.size() >= 1:
		var first_card = game_data.deck.pop_front()
		first_card.position = Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))
		add_child(first_card)
		first_card.play_sound()
		var first_card_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		first_card_tween.tween_property(first_card, 'global_position', %Pile.global_position, game_data.card_movement_speed)
		first_card.flip()
		await first_card_tween.finished
		remove_child(first_card)
		%Pile.discard(first_card)

func deal_card(player) -> void:
	if game_data.deck.size() >= 1:
		var card = game_data.deck.pop_front()
		card.position = Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))
		add_child(card)
		card.play_sound()
		var deal_card_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		deal_card_tween.tween_property(card, 'global_position', player.global_position, game_data.card_movement_speed / 3)
		await deal_card_tween.finished
		remove_child(card)
		player.add_hand(card, -1)

func draw_from_deck(player) -> void:
	if game_data.deck.size() > 0:
		var card = game_data.deck.pop_front()
		card.position = Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))
		add_child(card)
		card.play_sound()
		var draw_card_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		draw_card_tween.tween_property(card, 'global_position', player.get_node('NewCard').global_position, game_data.card_movement_speed)
		if player.is_player:
			if card.face == 'BACK':
				card.flip()
		await draw_card_tween.finished
		card.position = Vector2.ZERO
		if player.is_player:
			player.disable_cabo_button()
		remove_child(card)
		player.set_new_card(card)
		update()
		player.can_draw = false

func update() -> void:
	$Texture.frame = ceil((3.0 / 26.0) * type_convert(game_data.deck.size(), TYPE_FLOAT))
	$Card.position = Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))

func enable() -> void:
	$Card.enable_button()
	
func disable() -> void:
	$Card.disable_button()

func is_enabled() -> bool:
	return not $Card.disabled
	
func is_disabled() -> bool:
	return $Card.disabled
